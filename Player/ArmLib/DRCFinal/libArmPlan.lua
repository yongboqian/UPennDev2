-- libArmPlan
-- (c) 2014 Stephen McGill
-- Plan a path with the arm
local libArmPlan = {}
local procFunc = require'util'.procFunc
local mod_angle = require'util'.mod_angle
local vector = require'vector'
local vnorm = require'vector'.norm
local q = require'quaternion'
local T = require'Transform'
local tremove = require'table'.remove
local tinsert = require'table'.insert
local fabs = require'math'.abs
local min, max = require'math'.min, require'math'.max
local INFINITY = require'math'.huge
local EPSILON = 1e-2 * DEG_TO_RAD

-- Does not work for the infinite turn motors
local function sanitize(qPlanned, qNow)
	local qDiff = qPlanned - qNow
	local qDiffEffective = mod_angle(qDiff)
	if fabs(qDiffEffective) < fabs(qDiff) then
		return qNow + qDiffEffective
	else
		return qNow + qDiff
	end
end

local function sanitizeAll(iqArm, qArm0)
	local iqArm2 = {}
	for i, qNow in ipairs(qArm0) do
		if (i==5 or i==7) then
			-- TODO: Find the nearest
			iqArm2[i] = iqArm[i]
		else
			iqArm2[i] = sanitize(iqArm[i], qNow)
		end
	end
	return iqArm2
end

local function qDiff(iqArm, qArm0, qMin, qMax)
	local qD = {}
	for i, q0 in ipairs(qArm0) do
		qD[i] = (i==5 or i==7) and (iqArm[i] - q0) or sanitize(iqArm[i], q0)
	end
	return qD
end

-- Use the Jacobian
local speed_eps = 0.1 * 0.1
local c, p = 2, 10
local torch = require'torch'
local function get_delta_qwaistarm(self, vwTarget, qArm, qWaist)
	-- Penalty for joint limits
	local qMin, qMax, qRange =
		{unpack(self.qMin)}, {unpack(self.qMax)}, {unpack(self.qRange)}

	-- infinte rotation
	--[[
	for i, v in ipairs(qRange) do
		if i==5 or i==7 then
			qMin[i] = -2 * math.pi
			qMax[i] = 2 * math.pi
			qRange[i] = 4 * math.pi
		end
	end
	--]]

	assert(type(qArm)=='table', 'get_delta_qwaistarm | Bad qArm')
	assert(type(vwTarget)=='table', 'get_delta_qwaistarm | Bad vwTarget')

	local qWaistArm = {unpack(qArm)}
	if qWaist then
		tinsert(qWaistArm, 1, qWaist[1])
		tinsert(qMin, 1, -45*DEG_TO_RAD)
		tinsert(qMax, 1, 45*DEG_TO_RAD)
		tinsert(qRange, 1, 90*DEG_TO_RAD)
	end

	local l = {}
	for i, q in ipairs(qWaistArm) do
    l[i]= speed_eps + c * ((2*q - qMin[i] - qMax[i])/qRange[i]) ^ p
  end
	-- Calculate the pseudo inverse
	--print('self.jacobian', qArm, qWaist)
    --[[
    Thus, the damped least squares solution is equal to
    ∆θ = (J^T * J + λ^2 * I)^−1 * J^T * e
    --]]
    --[[
    TODO:
    It is easy to show that (J T J + λ 2 I) −1 J T = J T (JJ T + λ 2 I) −1 . Thus,
    ∆θ = J^T *(J * J^T + λ^2 * I)^−1 *e
    --]]
    --[[
    TODO:
    Additionally, (11) can be computed without needing to carry out the
matrix inversion, instead row operations can find f such that (JJ T +λ 2 I) f =
e and then J T f is the solution.
    --]]
		--[[
		-- TODO: Robot subtask performance with singularity robustness using optimal damped least-squares
		While (1) is not defined for λ = 0, (2) is as the
matrix (J*JT + λI) is invertible for λ = 0 provided J
has full row rank.
		--]]
	local J = torch.Tensor(self.jacobian(qArm, qWaist))
	local JT = J:t():clone()
	local lambda = torch.Tensor(l)
	local invInner = torch.inverse(torch.diag(lambda):addmm(JT, J))
	--print('invInner', invInner)
	local Jpseudoinv = torch.mm(invInner, JT)
	--print('Jpseudoinv', Jpseudoinv)
	local dqArm = torch.mv(Jpseudoinv, torch.Tensor(vwTarget))
	local null = torch.eye(#l) - Jpseudoinv * J
	return dqArm, null
end

local function get_distance(self, trGoal, qArm, qWaist)
	-- Grab our relative transform from here to the goal
	local fkArm = self.forward(qArm, qWaist)
	local invArm = T.inv(fkArm)
	--local here = invArm * trGoal --old ok one
	--local invGoal = T.inv(trGoal)
	local here = trGoal * invArm -- new good one
	--local here = invGoal * fkArm -- ??
	--local here = fkArm * invGoal -- opp
	--[[
	local dp2 = T.position(here2)
	local drpy2 = T.to_rpy(here2)
	local dp3 = T.position(here3)
	local drpy3 = T.to_rpy(here3)
	--]]

	-- Determine the position and angular velocity target
	local dp = T.position(here)
	local drpy = T.to_rpy(here)

	--print(vector.new(dp), vector.new(dp2), vector.new(dp3))

	local components = {vnorm(dp), vnorm(drpy)}
	return dp, drpy, components
end

-- Play the plan as a coroutine
-- Array of joint angles
-- Callback on sensed data
local function co_play(path, callback)
	local qArmSensed, qWaistSensed = coroutine.yield()
	if type(callback)=='function' then
		callback(qArmSensed, qWaistSensed)
	end

	for i, qArmPlanned in ipairs(path) do
		qArmSensed, qWaistSensed = coroutine.yield(qArmPlanned)
		if type(callback)=='function' then
			callback(qArmSensed, qWaistSensed)
		end
	end
	local qEnd = path[#path]
	return qEnd
end

local function co_play_waist(path, callback)
	local qArmSensed, qWaistSensed = coroutine.yield()
	if type(callback)=='function' then
		callback(qArmSensed, qWaistSensed)
	end
	for i, qArmPlanned in ipairs(path) do
		qArmSensed, qWaistSensed = coroutine.yield(
				{unpack(qArmPlanned, 2, #qArmPlanned)}, {qArmPlanned[1], 0})
		if type(callback)=='function' then
			callback(qArmSensed, qWaistSensed)
		end
	end
	local qEnd = path[#path]
	if not qEnd then return end
	return {unpack(qEnd, 2, #qEnd)}, {qEnd[1], 0}
end

-- Similar to SJ's method for the margin
local function find_shoulder_sj(self, tr, qArm)
	local minArm, maxArm, rangeArm = self.qMin, self.qMax, self.qRange
	local invArm = self.inverse
	local iqArm, margin, qBest
	local dMin, dMax
	--
	local maxmargin, margin = -INFINITY
	for i, q in ipairs(self.shoulderAngles) do
		iqArm = invArm(tr, qArm, q)
		-- Maximize the minimum margin
		dMin = iqArm - minArm
		dMax = iqArm - maxArm
		margin = INFINITY
		for _, v in ipairs(dMin) do
			-- don't worry about the yaw ones
			if iq~=5 and iq~=7 then margin = min(fabs(v), margin) end
		end
		for _, v in ipairs(dMax) do
			if iq~=5 and iq~=7 then margin = min(fabs(v), margin) end
		end
		if margin > maxmargin then
			maxmargin = margin
			qBest = iqArm
		end
	end
	return qBest
end

-- Weights: cusage, cdiff, ctight, cshoulder, cwrist
local defaultWeights = {0, 0, 0, 0, 2}
--
local function valid_cost(iq, qMin, qMax)
	for i, q in ipairs(iq) do
		if i==5 or i==7 then --inf turn
		elseif q<qMin[i]-EPSILON or q>qMax[i]+EPSILON then return INFINITY end
	end
	return 0
end
local IK_POS_ERROR_THRESH = 0.03
-- TODO: Fix the find_shoulder api
local function find_shoulder(self, tr, qArm, weights, qWaist)
	weights = weights or defaultWeights
	-- Form the inverses

	local iqArms = {}
	for i, q in ipairs(self.shoulderAngles) do
		local iq = self.inverse(tr, qArm, q, 0, qWaist)
		local iq2 = sanitizeAll(iq, qArm)
		tinsert(iqArms, vector.new(iq2))
	end
	-- Form the FKs
	local fks = {}

	for ic, iq in ipairs(iqArms) do
		fks[ic] = self.forward(iq, qWaist)
	end
	--
	local qMin, qMax = self.qMin, self.qMax
	local rangeArm, halfway = self.qRange, self.halves
	-- Cost for valid configurations
	local cvalid = {}
	for ic, iq in ipairs(iqArms) do tinsert(cvalid, valid_cost(iq, qMin, qMax) ) end
	-- FK sanity check
	local dps = {}
	local p_tr = vector.new(T.position(tr))
	for i, fk in ipairs(fks) do dps[i] = p_tr - T.position(fk) end
	local cfk = {}
	for ic, dp in ipairs(dps) do
		local ndp = vnorm(dp) -- NOTE: cost not in joint space
		tinsert(cfk, ndp<IK_POS_ERROR_THRESH and ndp or INFINITY)
	end
	-- Minimum Difference in angles
	local cdiff = {}
	for ic, iq in ipairs(iqArms) do
		--tinsert(cdiff, fabs(iq[3] - qArm[3]))
		tinsert(cdiff, vnorm(qDiff(iq, qArm, qMin, qMax)))
		--tinsert(cdiff, vnorm(iq - qArm))
	end
	-- Cost for being tight (Percentage)
	local ctight, wtight = {}, weights[3] or 0
	-- The margin from zero degrees away from the body
	local margin, ppi = 5*DEG_TO_RAD, math.pi
	for _, iq in ipairs(iqArms) do tinsert(ctight, fabs((iq[2]-margin))/ppi) end
	-- Usage cost (Worst Percentage)
	----[[
	local cusage, dRelative = {}
	for _, iq in ipairs(iqArms) do
		dRelative = ((iq - qMin) / rangeArm) - halfway
		-- Don't use the infinite yaw ones.  Treated later
		--tremove(dRelative, 7)
		--tremove(dRelative, 5)
		-- Don't use a cost based on the shoulderAngle
		tremove(dRelative, 3)
		tinsert(cusage, max(fabs(min(unpack(dRelative))), fabs(max(unpack(dRelative)))))
	end
	--]]
	-- Away from zero
	--[[
	local cusage, dRelative = {}
	for _, iq in ipairs(iqArms) do
		tinsert(cusage, max(fabs(min(unpack(iq))), fabs(max(unpack(iq)))))
	end
	--]]
	local cshoulder, wshoulder = {}, weights[4] or 0
	for _, iq in ipairs(iqArms) do
		tinsert(cshoulder, fabs(iq[3] - qArm[3]))
	end
	local cwrist, wwrist = {}, weights[5] or 2
	for _, iq in ipairs(iqArms) do
		tinsert(cwrist, fabs(iq[5]) + fabs(iq[7]))
	end

	-- Combined cost
	-- TODO: Tune the weights on a per-task basis (some tight, but not door)
	local cost = {}
	for ic, valid in ipairs(cvalid) do
		tinsert(cost, valid + cfk[ic]
			+ weights[1]*cusage[ic]
			+ weights[2]*cdiff[ic]
			+ wtight*ctight[ic]
			+ wshoulder*cshoulder[ic]
		)
	end
	-- Find the smallest cost
	local ibest, cbest = 0, INFINITY
	for i, c in ipairs(cost) do if c<cbest then cbest = c; ibest = i end end
	-- Return the least cost arms
	return iqArms[ibest], fks[ibest]
end

function libArmPlan.joint_preplan(self, plan)
	local prefix = string.format('joint_preplan (%s) | ', self.id)
	assert(type(plan)=='table', prefix..'Bad plan')
	local qArm0 = assert(plan.qArm0, prefix..'Need initial arm')
	local qWaist0 = assert(plan.qWaist0, prefix..'Need initial waist')
	local qArmF
	if type(plan.q)=='table' then
		qArmF = plan.q
	elseif plan.tr then
		local qArmFGuess = plan.qArmGuess or qArm0
		qArmF = self:find_shoulder(plan.tr, qArmFGuess, plan.weights, qWaist0)
		assert(type(qArmF)=='table', prefix..'No target shoulder solution')
	else
		error(prefix..'Need tr or q')
	end
	-- Set the limits and check compliance
	local qMin, qMax = self.qMin, self.qMax
	local dq_limit = self.dq_limit
	for i, q in ipairs(qArmF) do
		if i==5 or i==7 then
			-- No limit for infinite rotation :P
			--qArmF[i] = sanitize(qArmF[i], qArm0[i])
		else
			--[[
			assert(q+EPSILON>=qMin[i],
				string.format('%s Below qMin[%d] %g < %g', prefix, i, q, qMin[i]))
			assert(q-EPSILON<=qMax[i],
				string.format('%s Above qMax[%d] %g > %g', prefix, i, q, qMax[i]))
			--]]
			qArmF[i] = min(max(qMin[i], q), qMax[i])
		end
	end
	-- Set the timeout
	local hz, dt = self.hz, self.dt
	local qArm = vector.new(qArm0)
	local path = {}
	-- If given a duration, then check speed limit compliance
	if type(plan.duration)=='number' then
		if Config.debug.armplan then print(prefix..'Using duration:', plan.duration) end
		local dqTotal = qArmF - qArm0
		local dqdtAverage = dqTotal / plan.duration
		local dqAverage = dqdtAverage * dt
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			if fabs(dqAverage[i]) > limit then
				print(string.format(prefix.."dq[%d] |%g| > %g", i, dqAverage[i], lim))
				--return qArm
			end
			table.insert(usage, fabs(dqAverage[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage>1 then
			for i, qF in ipairs(dqAverage) do dqAverage[i] = qF / max_usage end
		end
		-- Form the plan
		local nsteps = plan.duration * hz
		for i=1,nsteps do
			qArm = qArm + dqAverage
			table.insert(path, qArm)
		end
		print(prefix..'Duration Steps:', #path)
		return co_play(path)
	end
	-- Timeout based
	local timeout = assert(plan.timeout, prefix..'No timeout')
	local nStepsTimeout = timeout * hz
	repeat
		local dqArmF = qArmF - qArm
		local dist = vnorm(dqArmF)
		if dist < 0.5*DEG_TO_RAD then break end
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqArmF[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage>1 then
			for i, qF in ipairs(dqArmF) do dqArmF[i] = qF / max_usage end
		end
		-- Apply the joint change
		qArm = qArm + dqArmF
		table.insert(path, qArm)
	until #path > nStepsTimeout
	-- Finish
	if Config.debug.armplan then
		print(prefix..'Timeout Steps:', #path)
		if #path > nStepsTimeout then print(prefix..'Timeout: ', #path) end
	end
	return co_play(path)
end

function libArmPlan.joint_waist_preplan(self, plan)
	local prefix = string.format('joint_waist_preplan (%s) | ', self.id)
	assert(type(plan)=='table', prefix..'Bad plan')
	local qArm0 = assert(plan.qArm0, prefix..'Need initial arm')
	local qWaist0 = assert(plan.qWaist0, prefix..'Need initial waist')
	-- If calling joint_waist, then should always have a final waist...
	local qWaistF = assert(plan.qWaistGuess, prefix..'Need final waist')
	local qArmF
	if type(plan.q)=='table' then
		qArmF = plan.q
	elseif plan.tr then
		local qArmFGuess = plan.qArmGuess or qArm0
		qArmF = self:find_shoulder(plan.tr, qArmFGuess, plan.weights, qWaistF)
		assert(type(qArmF)=='table', prefix..'No target shoulder solution')
	else
		error(prefix..'Need tr or q')
	end
	-- Form the waist/arm combo
	local qWaistArmF = {qWaistF[1], unpack(qArmF)}
	local qWaistArm0 = {qWaist0[1], unpack(qArm0)}
	-- Set the limits and check compliance
	local hz, dt = self.hz, self.dt
	local qMin = {-math.pi/3, unpack(self.qMin)}
	local qMax = {math.pi/3, unpack(self.qMax)}
	local dq_limit = {8*DEG_TO_RAD*dt, unpack(self.dq_limit)}

	-- Fix up the joint preplan
	-- TODO: this does not look right
	for i, q in ipairs(qWaistArmF) do
		if i==5 or i==7 then
			--qArmF[i] = sanitize1(qArmF[i], qArm0[i])
		else
			--[[
			assert(q+EPSILON>=qMin[i],
				string.format('%s Below qMin[%d] %g < %g', prefix, i, q, qMin[i]))
			assert(q-EPSILON<=qMax[i],
				string.format('%s Above qMax[%d] %g > %g', prefix, i, q, qMax[i]))
			--]]
			qWaistArmF[i] = min(max(qMin[i], q), qMax[i])
		end
	end
	-- Set the timeout
	local qWaistArm = vector.new(qWaistArm0)
	local path = {}
	-- If given a duration, then check speed limit compliance
	local duration = plan.duration
	if type(plan.duration)=='number' then
		if Config.debug.armplan then print(prefix..'Using duration:', plan.duration) end
		local dqTotal = qWaistArmF - qWaistArm0
		local dqdtAverage = dqTotal / plan.duration
		local dqAverage = dqdtAverage * dt
		for i, lim in ipairs(dq_limit) do
			assert(fabs(dqAverage[i]) <= lim,
				string.format("%s dq[%d] |%g| > %g", prefix, i, dqAverage[i], lim))
		end
		-- Form the plan
		local nsteps = plan.duration * hz
		for i=1,nsteps do
			qWaistArm = qWaistArm + dqAverage
			table.insert(path, qWaistArm)
		end
		print(prefix..'Steps:', #path)
		return co_play_waist(path)
	end
	-- Timeout based
	local timeout = assert(plan.timeout, prefix..'No timeout')
	local nStepsTimeout = math.ceil(timeout * hz)
	repeat
		local dqWaistArmF = qWaistArmF - qWaistArm
		local dist = vnorm(dqWaistArmF)
		if dist < 0.5*DEG_TO_RAD then break end
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqWaistArmF[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage>1 then
			for i, qF in ipairs(dqWaistArmF) do dqWaistArmF[i] = qF / max_usage end
		end
		-- Apply the joint change
		qWaistArm = qWaistArm + dqWaistArmF
		table.insert(path, qWaistArm)
	until #path > nStepsTimeout
	-- Finish
	if Config.debug.armplan then
		print(prefix..'Steps:', #path)
		if #path > nStepsTimeout then print(prefix..'Timeout: ', #path) end
	end
	return co_play_waist(plan)
end
-- Plan via Jacobian for just the arm
function libArmPlan.jacobian_preplan(self, plan)
	local prefix = string.format('jacobian_preplan (%s) | ', self.id)
	assert(type(plan)=='table', prefix..'Bad plan')
	local qArm0 = assert(plan.qArm0, prefix..'Need initial arm')
	local qWaist0 = assert(plan.qWaist0, prefix..'Need initial waist')
	-- Find a guess of the final arm configuration
	local qArmFGuess = plan.qArmGuess
	local trGoal
	if type(plan.q)=='table' then
		trGoal = self.forward(plan.q, qWaist0)
		qArmFGuess = plan.q
	elseif plan.tr then
		trGoal = plan.tr
		local weights = plan.weights
		qArmFGuess = plan.qArmGuess or self:find_shoulder(trGoal, qArm0, weights, qWaist0)
	else
		error(prefix..'Need tr or q')
	end
	-- Use straight jacobian if no guess
	if qArmFGuess then
		vector.new(qArmFGuess)
	else
		if Config.debug.armplan then
			print(prefix..'No guess found for the final!')
		end
	end
	-- Grab our limits
	local dq_limit = self.dq_limit
	local qMin, qMax = self.qMin, self.qMax

	-- Set the timing
	local timeout = assert(plan.timeout, prefix..'No timeout')
	local hz, dt = self.hz, self.dt
	local nStepsTimeout = math.ceil(timeout * hz)
	-- Initial position
	local qArm = vector.copy(qArm0)
	-- Begin
	local t0 = unix.time()
	local path = {}
	local dp, drpy, dist_components
	repeat
		-- Check if we are close enough
		dp, drpy, dist_components = get_distance(self, trGoal, qArm, qWaist0)

		--[[
		if #path<200 then
			print(vector.new(dp))
			print(vector.new(drpy))
			print(unpack(dist_components))
		end
		--]]

		if dist_components[1] < 0.01 and dist_components[2] < 2*DEG_TO_RAD then
			print(prefix..' close!', unpack(dist_components))
			break
		end

		-- Form our desired velocity
		local vwTarget = {unpack(dp)}
		vwTarget[4], vwTarget[5], vwTarget[6] = unpack(drpy)
		-- Grab the joint velocities needed to accomplish the se(3) velocities
		local dqdtArm, nullspace = get_delta_qwaistarm(self, vwTarget, qArm)
		-- Grab the velocities toward our guessed configuration, w/ or w/o null
		local dqdtCombo
		if qArmFGuess then
			--local dqdtNull = nullspace * torch.Tensor(qDiff(qArm, qArmFGuess, qMin, qMax))
			local dqdtNull = nullspace * torch.Tensor(qArm - qArmFGuess)
			dqdtCombo = dqdtArm - dqdtNull
		else
			dqdtCombo = dqdtArm
		end
		-- Respect the update rate, place as a lua table
		local dqCombo = vector.new(dqdtCombo:mul(dt))
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqCombo[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage > 1 then
			for i, dq in ipairs(dqCombo) do
				dqCombo[i] = dq / max_usage
			end
		end
		-- Apply the joint change (Creates a new table)
		local qOld = qArm
		qArm = qArm + dqCombo
		--print('qArm', qOld)
		-- Check joint limit compliance
		for i, q in ipairs(qArm) do
			if i==5 or i==7 then
				--qArm[i] = sanitize(q, qOld[i])
			else
				qArm[i] = min(max(qMin[i], q), qMax[i])
			end
		end
		-- Add to the path
		table.insert(path, qArm)
	until #path > nStepsTimeout
	local t1 = unix.time()
	-- Show the timing
	if Config.debug.armplan then
	  print(string.format('%s: %d steps (%d ms)', prefix, #path, (t1-t0)*1e3))
	end
	-- Play the plan
	local qArmF = co_play(path)
	if Config.debug.armplan then print(prefix..'qArmF', qArmF) end
	if not qArmF then return qArm end
	-- Hitting the timeout means we are done
	if #path >= nStepsTimeout then
		if Config.debug.armplan then
			print(prefix..'Timeout!', self.id, #path)
			print(prefix..'Distance', unpack(dist_components))
		end
		return qArmF
	end
	-- Goto the final
	if Config.debug.armplan then print(prefix..'Final find_shoulder') end
	local qArmF1 = self:find_shoulder(trGoal, qArm, {0,1,0}, qWaist0)
	if Config.debug.armplan then print(prefix..'Final solution', qArmF1) end
	if not qArmF1 then return qArmF end

	local final_plan = {
		q = qArmF1,
		qArm0 = qArmF,
		qWaist0 = qWaist0,
		duration = 1
	}
	if Config.debug.armplan then
	  print(prefix..'Final joint preplan')
		util.ptable(final_plan)
	end
	-- Use the pre-existing planner
	return libArmPlan.joint_preplan(self, final_plan)
end

-- Plan via Jacobian for waist and arm
function libArmPlan.jacobian_waist_preplan(self, plan)
	local prefix = string.format('jacobian_waist_preplan (%s) | ', self.id)
	assert(type(plan)=='table', prefix..'Bad plan')
	local qArm0 = assert(plan.qArm0, prefix..'Need initial arm')
	local qWaist0 = assert(plan.qWaist0, prefix..'Need initial waist')
	-- Find a guess of the final arm configuration
	local qWaistFGuess = plan.qWaistGuess or qWaist0
	local qArmFGuess, trGoal
	if type(plan.q)=='table' then
		trGoal = self.forward(plan.q, qWaistFGuess)
		qArmFGuess = plan.qArmGuess or plan.q
	elseif plan.tr then
		trGoal = plan.tr
		local weights = plan.weights
		qArmFGuess = plan.qArmGuess or self:find_shoulder(trGoal, qArm0, weights, qWaistFGuess)
	else
		error(prefix..'Need tr or q')
	end
	-- Use straight jacobian if no guess
	local qWaistArmFGuess
	if qArmFGuess then
		vector.new{qWaistFGuess[1], unpack(qArmFGuess)}
	else
		if Config.debug.armplan then
			print(prefix..'No guess found for the final!')
		end
	end
	-- Grab our limits
	local hz, dt = self.hz, self.dt
	local qMin = {-math.pi, unpack(self.qMin)}
	local qMax = {math.pi, unpack(self.qMax)}
	local dq_limit = {8*DEG_TO_RAD * dt, unpack(self.dq_limit)}
	-- Set the timing
	local timeout = assert(plan.timeout, prefix..'No timeout')
	local nStepsTimeout = math.ceil(timeout * hz)
	-- Initial position
	local qWaistArm = vector.new{qWaist0[1], unpack(qArm0)}
	-- Begin
	local t0 = unix.time()
	local path = {}
	repeat
		-- Check if we are close enough
		local dp, drpy, dist_components = get_distance(
			self, trGoal,
			{unpack(qWaistArm,2,#qWaistArm)}, {qWaistArm[1],0})
		-- Check if we are close enough
		if dist_components[1] < 0.01 and dist_components[2] < 2*DEG_TO_RAD then
			break
		end
		-- Form our desired velocity
		local vwTarget = {unpack(dp)}
		vwTarget[4], vwTarget[5], vwTarget[6] = unpack(drpy)
		-- Grab the joint velocities needed to accomplish the se(3) velocities
		local dqdtWaistArm, nullspace = get_delta_qwaistarm(
			self,
			vwTarget,
			{unpack(qWaistArm,2,#qWaistArm)},
			{qWaistArm[1], 0}
		)
		-- Grab the velocities toward our guessed configuration, w/ or w/o null
		local dqdtCombo
		if qWaistArmFGuess then
			local dqdtNull = nullspace * torch.Tensor(qWaistArm - qWaistArmFGuess)
			dqdtCombo = dqdtWaistArm - dqdtNull
		else
			dqdtCombo = dqdtWaistArm
		end
		-- Respect the update rate, place as a lua table
		local dqCombo = vector.new(dqdtCombo:mul(dt))
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqCombo[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage > 1 then
			for i, dq in ipairs(dqCombo) do
				dqCombo[i] = dq / max_usage
			end
		end
		-- Apply the joint change (Creates a new table)
		qWaistArm = qWaistArm + dqCombo
		-- Check joint limit compliance
		for i, q in ipairs(qWaistArm) do
			if i==5 or i==7 then
				-- TODO: sanitize
			else
				qWaistArm[i] = min(max(qMin[i], q), qMax[i])
			end
		end
		-- Add to the path
		table.insert(path, qWaistArm)
	until #path > nStepsTimeout
	-- Show the timing
	local t1 = unix.time()
	if Config.debug.armplan then
	  print(string.format('%s: %d steps (%d ms)', prefix, #path, (t1-t0)*1e3))
	end
	-- Play the plan
	local qArmF, qWaistF = co_play_waist(path)
	if #path==0 then return qArm0, qWaist0 end
	-- Hitting the timeout means we are done
	if #path >= nStepsTimeout then
		if Config.debug.armplan then print(prefix..'Timeout!', self.id, #path) end
		return qArmF, qWaistF
	end
	-- Goto the final
	local qArmF1 =
		self:find_shoulder(trGoal, qArmF, {0,1,0}, qWaistFGuess)
	if not qWaistArmF1 then
		if Config.debug.armplan then print(prefix..'No final solution found') end
		return qArmF, qWaistF
	end
	-- Use the pre-existing planner
	return libArmPlan.joint_waist_preplan(self, {
		q = qArmF1,
		qWaistGuess = qWaistFGuess,
		qArm0 = qArmF,
		qWaist0 = qWaistF,
		duration = 2
	})
end

-- Resume with an updated plan or empty table if no updates
function libArmPlan.jacobian_velocity(self, plan)
	local prefix = string.format('jacobian_preplan (%s) | ', self.id)
	-- Set the limits and check compliance
	local qMin, qMax = self.qMin, self.qMax
	local dq_limit = self.dq_limit
	-- While we have a plan, run the calculations
	local qArmSensed, qWaistSensed
	while type(plan)=='table' do
		-- Grab the joint velocities needed to accomplish the se(3) velocities
		local dqdtArm, nullspace = get_delta_qwaistarm(self, vwTarget, qArm)
		-- Grab the velocities toward our guessed configuration, w/ or w/o null
		local dqdtCombo
		if qArmFGuess then
			local dqdtNull = nullspace * torch.Tensor(qArm - qArmFGuess)
			dqdtCombo = dqdtArm - dqdtNull
		else
			dqdtCombo = dqdtArm
		end
		-- Respect the update rate, place as a lua table
		local dqCombo = vector.new(dqdtCombo:mul(dt))
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqCombo[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage > 1 then
			for i, dq in ipairs(dqCombo) do
				dqCombo[i] = dq / max_usage
			end
		end
		-- Apply the joint change (Creates a new table)
		qArm = qArm + dqCombo
		-- Check joint limit compliance
		for i, q in ipairs(qArm) do
			if i==5 or i==7 then
					-- TODO: Add sanitize
			else
				qArm[i] = min(max(qMin[i], q), qMax[i])
			end
		end
		-- Yield a command
		qArmSensed, qWaistSensed, plan = coroutine.yield()
	end
end

-- Resume with an updated plan or empty table if no updates
function libArmPlan.jacobian_wasit_velocity(self, plan)
	local prefix = string.format('jacobian_preplan (%s) | ', self.id)
	-- Set the limits
	local qMin = {-math.pi, unpack(self.qMin)}
	local qMax = {math.pi, unpack(self.qMax)}
	local dq_limit = {30*DEG_TO_RAD*self.dt, unpack(self.dq_limit)}
	-- While we have a plan, run the calculations
	local qArmSensed, qWaistSensed
	while type(plan)=='table' do
		-- Grab the joint velocities needed to accomplish the se(3) velocities
		local dqdtWaistArm, nullspace = get_delta_qwaistarm(
			self,
			vwTarget,
			{unpack(qWaistArm,2,#qWaistArm)},
			{qWaistArm[1], 0}
		)
		-- Grab the velocities toward our guessed configuration, w/ or w/o null
		local dqdtCombo
		if qWaistArmFGuess then
			local dqdtNull = nullspace * torch.Tensor(qWaistArm - qWaistArmFGuess)
			dqdtCombo = dqdtWaistArm - dqdtNull
		else
			dqdtCombo = dqdtWaistArm
		end
		-- Respect the update rate, place as a lua table
		local dqCombo = vector.new(dqdtCombo:mul(dt))
		-- Check the speed limit usage
		local usage = {}
		for i, limit in ipairs(dq_limit) do
			table.insert(usage, fabs(dqCombo[i]) / limit)
		end
		local max_usage = max(unpack(usage))
		if max_usage > 1 then
			for i, dq in ipairs(dqCombo) do
				dqCombo[i] = dq / max_usage
			end
		end
		-- Apply the joint change (Creates a new table)
		qWaistArm = qWaistArm + dqCombo
		-- Check joint limit compliance
		for i, q in ipairs(qWaistArm) do
			if i==5 or i==7 then
					-- TODO: Add sanitize
			else
				qWaistArm[i] = min(max(qMin[i], q), qMax[i])
			end
		end
		-- Yield a command
		qArmSensed, qWaistSensed, plan = coroutine.yield()
	end
end

-- Set the forward and inverse
local function set_chain(self, forward, inverse, jacobian)
	self.forward = assert(forward)
	self.inverse = assert(inverse)
	self.jacobian = jacobian
  return self
end

-- Set the iterator resolutions
local function set_limits(self, qMin, qMax, dqdt_limit)
	self.qMin = assert(qMin)
	self.qMax = assert(qMax)

	-- TODO: Check with SJ on the proper limits
	if self.id:lower():find'left' then
		print('left fix')
		qMin[2] = max(qMin[2], 0)
	end

	self.dqdt_limit = assert(dqdt_limit)
	self.qRange = qMax - qMin
  return self
end

-- Set the iterator resolutions
local function set_update_rate(self, hz)
	assert(type(hz)=='number', 'libArmPlan | Bad update rate for '..tostring(self.id))
	assert(type(self.dqdt_limit)=='table',
		'libArmPlan | Unknown dqdt_limit for '..tostring(self.id))
	self.hz = hz
	self.dt = 1/hz
	self.dq_limit = self.dqdt_limit / hz
  return self
end

local function set_shoulder_granularity(self, granularity)
	assert(type(granularity)=='number', 'Granularity not a number')
	local minShoulder, maxShoulder = self.qMin[3], self.qMax[3]
	local n = math.floor((maxShoulder - minShoulder) / granularity + 0.5)
	local shoulderAngles = {}
	for i=0,n do table.insert(shoulderAngles, minShoulder + i * granularity) end
	self.shoulderAngles = shoulderAngles
	return self
end

-- Still must set the forward and inverse kinematics
function libArmPlan.new_planner(id)
	local nq = 7
	local armOnes = vector.ones(nq)
	local armZeros = vector.zeros(nq)
	local obj = {
		id = id or 'Unknown',
		nq = nq,
		zeros = armZeros,
		ones = armOnes,
		halves = armOnes * 0.5,
		--
		shoulderAngles = nil,
		find_shoulder = find_shoulder,
		--
		set_chain = set_chain,
		set_limits = set_limits,
		set_update_rate = set_update_rate,
		set_shoulder_granularity = set_shoulder_granularity,
	}
	return obj
end

return libArmPlan
