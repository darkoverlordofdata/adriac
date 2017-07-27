/*******************************************************************************
 * Copyright 2017 darkoverlordofdata.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
namespace  Sdx.Math 
{
    
    
    public class Tween : Object
    {
        public const int INFINITY = -1;
        
        public enum TweenCallback {
            BEGIN = 0x01,
            START = 0x02,
            END = 0x04,
            COMPLETE = 0x08,
            BACK_BEGIN = 0x10,
            BACK_START = 0x20,
            BACK_END = 0x40,
            BACK_COMPLETE = 0x80,
            ANY_FORWARD = 0x0F,
            ANY_BACKWARD = 0xF0,
            ANY = 0xFF
        }
        public delegate void TweenCallbackOnEvent(int type, Tween source);

        
        // -------------------------------------------------------------------------
        // Static -- tween accessors
        // -------------------------------------------------------------------------
        public static GenericArray<TweenAccessor> registeredAccessors;
        public static Stack<Tween> pool;
        public static int combinedAttrsLimit = 3;
        /**
         * Changes the limit for combined attributes. Defaults to 3 to reduce
         * memory footprint.
         */
        public static void SetCombinedAttributesLimit(int limit) 
        {
            combinedAttrsLimit = limit;
        }

        public void* target;
        public int type;
        public Interpolation equation;
        public TweenAccessor accessor;
        public bool isFrom;
        public bool isRelative;
        public int combinedAttrsCnt;
        public int waypointsCnt;
        public float[] targetValues = new float[combinedAttrsLimit];
        public float[] startValues = new float[combinedAttrsLimit];
	    public float[] accessorBuffer = new float[combinedAttrsLimit];

        public bool isInitialized;
        public bool isAutoRemoveEnabled;
        public bool isAutoStartEnabled;
        public int step;
        public int repeatCnt;
        public bool isIterationStep;
        public bool isYoyo;

        // Timings
        public float delay;
        public float duration;
        public float repeatDelay;
        public float currentTime;
        public float deltaTime;
        public bool isStarted;  // true when the object is started
        public bool isFinished; // true when all repetitions are done
        public bool isKilled;   // true if kill() was called
        public bool isPaused;   // true if pause() was called

        public TweenCallbackOnEvent callback;
        public int callbackTriggers;
        public void* userData;
        
        public static void Init()
        {
            pool = new Stack<Tween>();
            registeredAccessors = new GenericArray<TweenAccessor>();
        }

        /**
         * Registers an accessor with the class of an object. This accessor will be
         * used by tweens applied to every objects implementing the registered
         * class, or inheriting from it.
         *
         * @param someClass An object class.
         * @param defaultAccessor The accessor that will be used to tween any
         * object of klass "someClass".x`
         */
        public static void RegisterAccessor(int tweenType, TweenAccessor defaultAccessor)
        {
            if (registeredAccessors.length < tweenType)
                registeredAccessors.length = tweenType+1;

            registeredAccessors.Set(tweenType, defaultAccessor);
        }


        /**
         * Gets the registered TweenAccessor associated with the given object class.
         *
         * @param someClass An object class.
         */
        public static TweenAccessor GetRegisteredAccessor(int tweenType) 
        {
            return registeredAccessors.Get(tweenType);
        }

        // -------------------------------------------------------------------------
        // Static -- factories
        // -------------------------------------------------------------------------

        public static Tween To(void* target, int tweenType, float duration) 
        {
            var tween = pool.IsEmpty() ? new Tween() : pool.Pop().Reset();
            tween.Setup(target, tweenType, duration);
            tween.Ease(Interpolation.quadInOut);
            return tween;
        }

        public static Tween From(void* target, int tweenType, float duration) 
        {
            var tween = pool.IsEmpty() ? new Tween() : pool.Pop().Reset();
            tween.Setup(target, tweenType, duration);
            tween.Ease(Interpolation.quadInOut);
            tween.isFrom = true;
            return tween;
        }

        public static Tween Set(void* target, int tweenType)
        {
            var tween = pool.IsEmpty() ? new Tween() : pool.Pop().Reset();
            tween.Setup(target, tweenType, 0);
            tween.Ease(Interpolation.quadInOut);
            return tween;
        }

        public static Tween Call(TweenCallbackOnEvent callback)
        {
            var tween = pool.IsEmpty() ? new Tween() : pool.Pop().Reset();
            tween.Setup(null, -1, 0);
            tween.SetCallback(callback);
		    tween.SetCallbackTriggers(TweenCallback.START);
            return tween;
        }

        public static Tween Mark()
        {
            var tween = pool.IsEmpty() ? new Tween() : pool.Pop().Reset();
            tween.Setup(null, -1, 0);
            return tween;
        }

        // -------------------------------------------------------------------------
        // Setup
        // -------------------------------------------------------------------------
        public Tween()
        {
            Reset();
        }
        
        public Tween Reset()
        {
            step = -2;
            repeatCnt = 0;
            isIterationStep = isYoyo = false;

            delay = duration = repeatDelay = currentTime = deltaTime = 0;
            isStarted = isInitialized = isFinished = isKilled = isPaused = false;

            callback = null;
            callbackTriggers = TweenCallback.COMPLETE;
            userData = null;

            isAutoRemoveEnabled = isAutoStartEnabled = true;

            target = null;
            accessor = null;
            type = -1;
            equation = null;

            isFrom = isRelative = false;
            combinedAttrsCnt = waypointsCnt = 0;
            if (accessorBuffer.length != combinedAttrsLimit) {
                accessorBuffer = new float[combinedAttrsLimit];
            }
            return this;
        }
        public void Setup(void* target, int tweenType, float duration)
        {
		    if (duration < 0) throw new Exception.RuntimeException("Duration can't be negative");
            this.target = target;
            this.type = tweenType;
            this.duration = duration;
        }

        // -------------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------------
        public Tween Ease(Interpolation easeEquation)
        {
            equation = easeEquation;
            return this;
        }

        /**
         * Sets the target values of the interpolation. The interpolation will run
         * from the <b>values at start time (after the delay, if any)</b> to these
         * target values.
         * <p/>
         *
         * To sum-up:<br/>
         * - start values: values at start time, after delay<br/>
         * - end values: params
         *
         * @param targetValues The target values of the interpolation.
         * @return The current tween, for chaining instructions.
         */
        public Tween Target(float[] targetValues)
        {
            this.targetValues = new float[targetValues.length];

            for (var i=0; i < targetValues.length; i++) 
            {
                this.targetValues[i] = targetValues[i];
            }
            return this;
        }

        /**
         * Sets the target values of the interpolation, relatively to the <b>values
         * at start time (after the delay, if any)</b>.
         * <p/>
         *
         * To sum-up:<br/>
         * - start values: values at start time, after delay<br/>
         * - end values: params + values at start time, after delay
         *
         * @param targetValues The relative target values of the interpolation.
         * @return The current tween, for chaining instructions.
         */
        public Tween TargetRelative(float[] targetValues)
        {
            isRelative = true;
            this.targetValues = new float[targetValues.length];

            for (var i=0; i < targetValues.length; i++) 
            {
                this.targetValues[i] = isInitialized ? targetValues[i] + startValues[i] : targetValues[i];
            }
            return this;
        }

        public Tween Start(TweenManager? manager = null)
        {
            if (manager == null)
            {
                Build();
                currentTime = 0;
                isStarted = true;
            }
            else
            {
                manager.Add(this);
            }
            return this;
        }
        public Tween Delay(float delay)
        {
            this.delay += delay;
            return this;
        }
        public void Kill()
        {
            isKilled = true;
        }
        public void Pause()
        {
            isPaused = true;
        }

        public void Resume()
        {
            isPaused = false;
        }

        public Tween Repeat(int count, float delay=0)
        {
            if (isStarted) throw new Exception.RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
            repeatCnt = count;
            repeatDelay = delay >= 0 ? delay : 0;
            isYoyo = false;
            return this;
            
        }

        public Tween RepeatYoyo(int count, float delay=0)
        {
            if (isStarted) throw new Exception.RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
            repeatCnt = count;
            repeatDelay = delay >= 0 ? delay : 0;
            isYoyo = true;
            return this;
            
        }

        public Tween SetCallback(TweenCallbackOnEvent callback)
        {
            this.callback = callback;
            return this;
        }

        public Tween SetCallbackTriggers(int flags)
        {
            callbackTriggers = flags;
            return this;
        }

        public Tween SetUserData(void* data)
        {
            userData = data;
            return this;
        }

        public float GetDelay()
        {
            return delay;
        }

        public float GetDuration()
        {
            return duration;
        }

        public int GetRepeatCount()
        {
            return repeatCnt;
        }

        public float GetRepeatDelay()
        {
    		return repeatDelay;
        }

        public float GetFullDuration() 
        {
            if (repeatCnt < 0) return -1;
            return delay + duration + (repeatDelay + duration) * repeatCnt;
        }

        public void* GetUserData()
        {
            return userData;
        }

        public int GetStep() 
        {
            return step;
        }

        public float GetCurrentTime() 
        {
            return currentTime;
        }
        
        public bool IsStarted() 
        {
            return isStarted;
        }
        
        public bool IsInitialized() 
        {
            return isInitialized;
        }
        
        public bool IsFinished() 
        {
            return isFinished || isKilled;
        }

        public bool IsYoyo() 
        {
            return isYoyo;
        }

        public bool IsPaused() 
        {
            return isPaused;
        }

        public void CallCallback(int type) 
        {
            //  print("CallCallback %d\n", type);
            if (callback != null && (callbackTriggers & type) > 0) callback(type, this);
        }
        

        public bool IsReverse(int step) 
        {
            return isYoyo && GLib.Math.fabs(step%4) == 2;
        }

        public bool IsValid(int step) 
        {
            return (step >= 0 && step <= repeatCnt*2) || repeatCnt < 0;
        }

        public void KillTarget(void* target, int tweenType=-1) {
            if (ContainsTarget(target, tweenType)) Kill();
        }
        
        public void Update(float delta)
        {
            //  print(" isStarted %s\n", isStarted.ToString());
            //  print(" isPaused %s\n", isPaused.ToString());
            //  print(" isKilled %s\n", isKilled.ToString());
            if (!isStarted || isPaused || isKilled) return;

            deltaTime = delta;

            if (!isInitialized) {
                Initialize();
            }

            if (isInitialized) {
                TestRelaunch();
                UpdateStep();
                TestCompletion();
            }

            currentTime += deltaTime;
            deltaTime = 0;

        }

        public void Initialize() 
        {
            if (currentTime+deltaTime >= delay) 
            {
                InitializeOverride();
                isInitialized = true;
                isIterationStep = true;
                step = 0;
                deltaTime -= delay-currentTime;
                currentTime = 0;
                CallCallback(TweenCallback.BEGIN);
                CallCallback(TweenCallback.START);
            }
        }
        
        public void TestRelaunch() 
        {
            if (!isIterationStep && repeatCnt >= 0 && step < 0 && currentTime+deltaTime >= 0) 
            {
                assert(step == -1);
                isIterationStep = true;
                step = 0;
                float delta = 0-currentTime;
                deltaTime -= delta;
                currentTime = 0;
                CallCallback(TweenCallback.BEGIN);
                CallCallback(TweenCallback.START);
                UpdateOverride(step, step-1, isIterationStep, delta);

            } 
            else if (!isIterationStep && repeatCnt >= 0 && step > repeatCnt*2 && currentTime+deltaTime < 0) 
            {
                assert(step == repeatCnt*2 + 1);
                isIterationStep = true;
                step = repeatCnt*2;
                float delta = 0-currentTime;
                deltaTime -= delta;
                currentTime = duration;
                CallCallback(TweenCallback.BACK_BEGIN);
                CallCallback(TweenCallback.BACK_START);
                UpdateOverride(step, step+1, isIterationStep, delta);
            }
        }

        public void UpdateStep() 
        {
            while (IsValid(step)) 
            {
                if (!isIterationStep && currentTime+deltaTime <= 0) 
                {
                    isIterationStep = true;
                    step -= 1;

                    float delta = 0-currentTime;
                    deltaTime -= delta;
                    currentTime = duration;

                    if (IsReverse(step)) ForceStartValues(); else ForceEndValues();
                    CallCallback(TweenCallback.BACK_START);
                    UpdateOverride(step, step+1, isIterationStep, delta);

                } 
                else if (!isIterationStep && currentTime+deltaTime >= repeatDelay) 
                {
                    isIterationStep = true;
                    step += 1;

                    float delta = repeatDelay-currentTime;
                    deltaTime -= delta;
                    currentTime = 0;

                    if (IsReverse(step)) ForceEndValues(); else ForceStartValues();
                    CallCallback(TweenCallback.START);
                    UpdateOverride(step, step-1, isIterationStep, delta);

                } 
                else if (isIterationStep && currentTime+deltaTime < 0) 
                {
                    isIterationStep = false;
                    step -= 1;

                    float delta = 0-currentTime;
                    deltaTime -= delta;
                    currentTime = 0;

                    UpdateOverride(step, step+1, isIterationStep, delta);
                    CallCallback(TweenCallback.BACK_END);

                    if (step < 0 && repeatCnt >= 0) CallCallback(TweenCallback.BACK_COMPLETE);
                    else currentTime = repeatDelay;

                } 
                else if (isIterationStep && currentTime+deltaTime > duration) 
                {
                    isIterationStep = false;
                    step += 1;

                    float delta = duration-currentTime;
                    deltaTime -= delta;
                    currentTime = duration;

                    UpdateOverride(step, step-1, isIterationStep, delta);
                    CallCallback(TweenCallback.END);

                    if (step > repeatCnt*2 && repeatCnt >= 0) CallCallback(TweenCallback.COMPLETE);
                    currentTime = 0;

                } 
                else if (isIterationStep) 
                {
                    float delta = deltaTime;
                    deltaTime -= delta;
                    currentTime += delta;
                    UpdateOverride(step, step, isIterationStep, delta);
                    break;

                } 
                else 
                {
                    float delta = deltaTime;
                    deltaTime -= delta;
                    currentTime += delta;
                    break;
                }
            }
        }
            
        public void TestCompletion() 
        {
            isFinished = repeatCnt >= 0 && (step > repeatCnt*2 || step < 0);
        }

        public Tween Build()
        {
		    if (target == null) return this;
            accessor = registeredAccessors.Get(type);
            if (accessor != null) 
                combinedAttrsCnt = accessor.GetValues(target, type, ref accessorBuffer);
            else
                throw new Exception.RuntimeException("No TweenAccessor was found for the target");

            if (combinedAttrsCnt > combinedAttrsLimit) 
                throw new Exception.IllegalArgumentException("CombinedAttrsLimitReached");
            return this;
        }

        public void InitializeOverride() 
        {
            if (target == null) return;

            accessor.GetValues(target, type, ref startValues);

            for (int i=0; i<combinedAttrsCnt; i++) 
            {
                targetValues[i] += isRelative ? startValues[i] : 0;
                if (isFrom) 
                {
                    float tmp = startValues[i];
                    startValues[i] = targetValues[i];
                    targetValues[i] = tmp;
                }
            }
        }
       
        public void UpdateOverride(int step, int lastStep, bool isIterationStep, float delta) 
        {
            if (target == null || equation == null) return;

            // Case iteration end has been reached
            if (!isIterationStep && step > lastStep) 
            {
                if (IsReverse(lastStep))
                    accessor.SetValues(target, type, ref startValues);
                else
                    accessor.SetValues(target, type, ref targetValues);
                return;
            }

            if (!isIterationStep && step < lastStep) 
            {
                if (IsReverse(lastStep))
                    accessor.SetValues(target, type, ref targetValues);
                else
                    accessor.SetValues(target, type, ref startValues);
                return;
            }

            // Validation
            assert(isIterationStep);
            assert(GetCurrentTime() >= 0);
            assert(GetCurrentTime() <= duration);

            // Case duration equals zero

            if (duration < 0.00000000001f && delta > -0.00000000001f) 
            {
                if (IsReverse(step))
                    accessor.SetValues(target, type, ref targetValues);
                else
                    accessor.SetValues(target, type, ref startValues);
                return;
            }

            if (duration < 0.00000000001f && delta < 0.00000000001f) 
            {
                if (IsReverse(step))
                    accessor.SetValues(target, type, ref startValues);
                else
                    accessor.SetValues(target, type, ref targetValues);
                return;
            }
            float time = IsReverse(step) ? duration - GetCurrentTime() : GetCurrentTime();
            float t = equation.Apply(time/duration);
			for (int i=0; i<combinedAttrsCnt; i++) {
				accessorBuffer[i] = startValues[i] + t * (targetValues[i] - startValues[i]);
			}
		    accessor.SetValues(target, type, ref accessorBuffer);

        }
        
        public void ForceStartValues() 
        {
            if (target == null) return;
            accessor.SetValues(target, type, ref startValues);
        }

        public void ForceEndValues() 
        {
            if (target == null) return;
            accessor.SetValues(target, type, ref targetValues);
        }


        public bool ContainsTarget(void* target, int tweenType=-1) {
            return tweenType < 0
                ? this.target == target
                : this.target == target && this.type == tweenType;
        }
        

    }

}