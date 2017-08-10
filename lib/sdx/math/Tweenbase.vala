/* ******************************************************************************
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
    public enum TimelineModes { SEQUENCE, PARALLEL }
    public enum TweenKind { TWEEN, TIMELINE }
    public delegate void TweenCallbackOnEvent(int type, Tweenbase source);
    /**
     * BaseTween is the base class of Tween and Timeline. It defines the
     * iteration engine used to play animations for any number of times, and in
     * any direction, at any speed.
     * <p/>
     *
     * It is responsible for calling the different callbacks at the right moments,
     * and for making sure that every callbacks are triggered, even if the update
     * engine gets a big delta time at once.
     *
     * based on code by  Aurelien Ribon
     * @see Tween
     * @see Timeline
     */
    public class Tweenbase : Object
    {
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

        protected TweenKind kind;
	    // General
        private int step;
        private int repeatCnt;
        private bool isIterationStep;
        private bool isYoyo;

        // Timings
        protected float delay;
        protected float duration;
        private float repeatDelay;
        private float currentTime;
        private float deltaTime;
        private bool isStarted;  // true when the object is started
        private bool isInitialized; // true after the delay
        private bool isFinished; // true when all repetitions are done
        private bool isKilled;   // true when kill was called
        private bool isPaused;   // true when pause was called

	    // Misc
        private TweenCallbackOnEvent callback;
        private int callbackTriggers;
        private void* userData;

	    // Package access
        public bool isAutoRemoveEnabled;
        public bool isAutoStartEnabled;
        
        // -------------------------------------------------------------------------
        // Static -- misc
        // -------------------------------------------------------------------------

        /**
         * Used as parameter in {@link Repeat} and
         * {@link RepeatYoyo} methods.
         */
        protected static int combinedAttrsLimit = 3;
        protected static int waypointsLimit = 0;

        // -------------------------------------------------------------------------
        // Static -- pool
        // -------------------------------------------------------------------------
        public static Stack<Tweenbase> pool;

        // -------------------------------------------------------------------------
        // Static -- tween accessors
        // -------------------------------------------------------------------------
        //  public static HashTable<string,TweenAccessor> registeredAccessors;
        public static HashTable<void*,TweenAccessor> registeredAccessors;

        // -------------------------------------------------------------------------
        // Attributes (Tween)
        // -------------------------------------------------------------------------

        // Main
        protected void* target;
        protected Class* targetClass;
        protected TweenAccessor accessor;
        protected int type;
        protected Interpolation equation;

    	// General
        protected bool isFrom;
        protected bool isRelative;
        protected int combinedAttrsCnt;
        protected int waypointsCnt;
    
        // Values
        protected float[] startValues = new float[combinedAttrsLimit];
        protected float[] targetValues = new float[combinedAttrsLimit];

    	// Buffers
	    protected float[] accessorBuffer = new float[combinedAttrsLimit];

        
        // -------------------------------------------------------------------------
        // Attributes (Timeline)
        // -------------------------------------------------------------------------
        //  public enum Modes {SEQUENCE, PARALLEL}

        protected GenericArray<Tweenbase> children;
        protected Tweenbase current;
        protected Tweenbase parent;
        protected TimelineModes mode;
        protected bool isBuilt;

        public delegate Tweenbase TweenReset();

        // -------------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------------

        /**
         * Builds and validates the object. Only needed if you want to finalize a
         * tween or timeline without starting it, since a call to ".start()" also
         * calls this method.
         *
         * @return The current object, for chaining instructions.
         */
        public delegate Tweenbase TweenBuild();
        /**
         * Stops and resets the tween or timeline, and sends it to its pool, for
         * later reuse. Note that if you use a {@link TweenManager}, this method
         * is automatically called once the animation is finished.
         */
        public delegate void TweenFree();
        public delegate Tweenbase TweenStart(TweenManager? manager = null);

        
        /* Virtual methods */
        protected TweenReset Reset = () => {};
        public TweenBuild Build = () => {};
        public TweenFree Free = () => {};
        public TweenStart Start = (manager) => {};

        public Tweenbase()
        {
            Reset = () =>
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
                return this;
            };

            Start = (manager) =>
            {
                if (manager == null)
                {
                    /**
                     * Starts or restarts the object unmanaged. You will need to take care of
                     * its life-cycle. If you want the tween to be managed for you, use a
                     * {@link TweenManager}.
                     *
                     * @return The current object, for chaining instructions.
                     */
                    Build();
                    currentTime = 0;
                    isStarted = true;
                }
                else
                {
                    /**
                     * Convenience method to add an object to a manager. Its life-cycle will be
                     * handled for you. Relax and enjoy the animation.
                     *
                     * @return The current object, for chaining instructions.
                     */
                    manager.Add(this);
                }
                return this;
            };
        }

        //  public Tweenbase Start(TweenManager? manager = null)
        //  {
        //      if (manager == null)
        //      {
        //          /**
        //           * Starts or restarts the object unmanaged. You will need to take care of
        //           * its life-cycle. If you want the tween to be managed for you, use a
        //           * {@link TweenManager}.
        //           *
        //           * @return The current object, for chaining instructions.
        //           */
        //          Build();
        //          currentTime = 0;
        //          isStarted = true;
        //      }
        //      else
        //      {
        //          /**
        //           * Convenience method to add an object to a manager. Its life-cycle will be
        //           * handled for you. Relax and enjoy the animation.
        //           *
        //           * @return The current object, for chaining instructions.
        //           */
        //          manager.Add(this);
        //      }
        //      return this;
        //  }
        /**
         * Adds a delay to the tween or timeline.
         *
         * @param delay A duration.
         * @return The current object, for chaining instructions.
         */
        public Tweenbase Delay(float delay)
        {
            this.delay += delay;
            return this;
        }

        /**
         * Kills the tween or timeline. If you are using a TweenManager, this object
         * will be removed automatically.
         */
        public void Kill()
        {
            isKilled = true;
        }
        /**
         * Pauses the tween or timeline. Further update calls won't have any effect.
         */
        public void Pause()
        {
            isPaused = true;
        }

        /**
         * Resumes the tween or timeline. Has no effect is it was no already paused.
         */
        public void Resume()
        {
            isPaused = false;
        }

        /**
         * Repeats the tween or timeline for a given number of times.
         * @param count The number of repetitions. For infinite repetition,
         * use Tween.INFINITY, or a negative number.
         *
         * @param delay A delay between each iteration.
         * @return The current tween or timeline, for chaining instructions.
         */
        public Tweenbase Repeat(int count, float delay=0)
        {
            if (isStarted) throw new Exception.RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
            repeatCnt = count;
            repeatDelay = delay >= 0 ? delay : 0;
            isYoyo = false;
            return this;
            
        }

        /**
         * Repeats the tween or timeline for a given number of times.
         * Every two iterations, it will be played backwards.
         *
         * @param count The number of repetitions. For infinite repetition,
         * use Tween.INFINITY, or '-1'.
         * @param delay A delay before each repetition.
         * @return The current tween or timeline, for chaining instructions.
         */
        public Tweenbase RepeatYoyo(int count, float delay=0)
        {
            if (isStarted) throw new Exception.RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
            repeatCnt = count;
            repeatDelay = delay >= 0 ? delay : 0;
            isYoyo = true;
            return this;
            
        }

        /**
         * Sets the callback. By default, it will be fired at the completion of the
         * tween or timeline (event COMPLETE). If you want to change this behavior
         * and add more triggers, use the {@link SetCallbackTriggers} method.
         *
         * @see TweenCallback
         */
        public Tweenbase SetCallback(TweenCallbackOnEvent callback)
        {
            this.callback = callback;
            return this;
        }
        
        /**
         * Changes the triggers of the callback. The available triggers, listed as
         * members of the {@link TweenCallback} interface, are:
         *
         *  * ''BEGIN'': right after the delay (if any)
         *  * ''START'': at each iteration beginning
         *  * ''END'': at each iteration ending, before the repeat delay
         *  * ''COMPLETE'': at last END event
         *  * ''BACK_BEGIN'': at the beginning of the first backward iteration
         *  * ''BACK_START'': at each backward iteration beginning, after the repeat delay
         *  * ''BACK_END'': at each backward iteration ending
         *  * ''BACK_COMPLETE'': at last BACK_END event
         *
         * {{{
         * forward :      BEGIN                                   COMPLETE
         * forward :      START    END      START    END      START    END
         * |--------------[XXXXXXXXXX]------[XXXXXXXXXX]------[XXXXXXXXXX]
         * backward:      bEND  bSTART      bEND  bSTART      bEND  bSTART
         * backward:      bCOMPLETE                                 bBEGIN
         * }}}
         *
         * @param flags one or more triggers, separated by the '|' operator.
         * @see TweenCallback
         */
        public Tweenbase SetCallbackTriggers(int flags)
        {
            callbackTriggers = flags;
            return this;
        }

        /**
         * Attaches an object to this tween or timeline. It can be useful in order
         * to retrieve some data from a TweenCallback.
         *
         * @param data Any kind of object.
         * @return The current tween or timeline, for chaining instructions.
         */
        public Tweenbase SetUserData(void* data)
        {
            userData = data;
            return this;
        }

        // -------------------------------------------------------------------------
        // Getters
        // -------------------------------------------------------------------------

        /**
         * Gets the delay of the tween or timeline. Nothing will happen before
         * this delay.
         */
        public float GetDelay()
        {
            return delay;
        }

        /**
         * Gets the duration of a single iteration.
         */
        public float GetDuration()
        {
            return duration;
        }

        /**
         * Gets the number of iterations that will be played.
         */
        public int GetRepeatCount()
        {
            return repeatCnt;
        }
        
        /**
         * Gets the delay occuring between two iterations.
         */
        public float GetRepeatDelay()
        {
    		return repeatDelay;
        }
        
        /**
         * Returns the complete duration, including initial delay and repetitions.
         * The formula is as follows:
         * {{{
         * fullDuration = delay + duration + (repeatDelay + duration) * repeatCnt
         * }}}
         */
        public float GetFullDuration() 
        {
            if (repeatCnt < 0) return -1;
            return delay + duration + (repeatDelay + duration) * repeatCnt;
        }

        /**
         * Gets the attached data, or null if none.
         */
        public void* GetUserData()
        {
            return userData;
        }

        /**
         * Gets the id of the current step. Values are as follows:
         * 
         *  * even numbers mean that an iteration is playing,
         *  * odd numbers mean that we are between two iterations,
         *  * -2 means that the initial delay has not ended,
         *  * -1 means that we are before the first iteration,
         *  * repeatCount*2 + 1 means that we are after the last iteration
         */
        public int GetStep() 
        {
            return step;
        }

        /**
         * Gets the local time.
         */
        public float GetCurrentTime() 
        {
            return currentTime;
        }
        
        /**
         * Returns true if the tween or timeline has been started.
         */
        public bool IsStarted() 
        {
            return isStarted;
        }
        
        /**
         * Returns true if the tween or timeline has been initialized. Starting
         * values for tweens are stored at initialization time. This initialization
         * takes place right after the initial delay, if any.
         */
        public bool IsInitialized() 
        {
            return isInitialized;
        }
        
        /**
         * Returns true if the tween is finished (i.e. if the tween has reached
         * its end or has been killed). If you don't use a TweenManager, you may
         * want to call {@link Free} to reuse the object later.
         */
        public bool IsFinished() 
        {
            return isFinished || isKilled;
        }

        /**
         * Returns true if the iterations are played as yoyo. Yoyo means that
         * every two iterations, the animation will be played backwards.
         */
        public bool IsYoyo() 
        {
            return isYoyo;
        }

        /**
         * Returns true if the tween or timeline is currently paused.
         */
        public bool IsPaused() 
        {
            return isPaused;
        }

        // -------------------------------------------------------------------------
        // Abstract API
        // -------------------------------------------------------------------------
        public delegate void TweenForceStartValues();
        public delegate void TweenForceEndValues();
        public delegate bool TweenContainsTarget(void* target, int tweenType=-1);
       
        protected TweenForceStartValues ForceStartValues = () => {};
        protected TweenForceEndValues ForceEndValues = () => {};
        public TweenContainsTarget ContainsTarget = (target, tweenType) => {};

        // -------------------------------------------------------------------------
        // Protected API
        // -------------------------------------------------------------------------
        public delegate void TweenInitializeOverride();
        public delegate void TweenUpdateOverride(int step, int lastStep, bool isIterationStep, float delta);

        protected TweenInitializeOverride InitializeOverride = () => {}; 
        protected TweenUpdateOverride UpdateOverride = (step, lastStep, isIterationStep, delta) => {}; 

        protected void ForceToStart() 
        {
            currentTime = -delay;
            step = -1;
            isIterationStep = false;
            if (IsReverse(0)) ForceEndValues();
            else ForceStartValues();
        }

        protected void ForceToEnd(float time) 
        {
            currentTime = time - GetFullDuration();
            step = repeatCnt*2 + 1;
            isIterationStep = false;
            if (IsReverse(repeatCnt*2)) ForceStartValues();
            else ForceEndValues();
        }
        
        protected void CallCallback(int type) 
        {
            //  print("CallCallback %d\n", type);
            if (callback != null && (callbackTriggers & type) > 0) callback(type, this);
        }
        

        protected bool IsReverse(int step) 
        {
            return isYoyo && GLib.Math.fabs(step%4) == 2;
        }

        protected bool IsValid(int step) 
        {
            return (step >= 0 && step <= repeatCnt*2) || repeatCnt < 0;
        }

        public void KillTarget(void* target, int tweenType=-1) {
            if (ContainsTarget(target, tweenType)) Kill();
        }

        // -------------------------------------------------------------------------
        // Update engine
        // -------------------------------------------------------------------------

        /**
         * Updates the tween or timeline state. 
         * ''You may want to use a TweenManager to update objects for you.''
         *
         * Slow motion, fast motion and backward play can be easily achieved by
         * tweaking this delta time. Multiply it by -1 to play the animation
         * backward, or by 0.5 to play it twice slower than its normal speed.
         *
         * @param delta A delta time between now and the last call.
         */
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

        private void Initialize() 
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
        
        private void TestRelaunch() 
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

        private void UpdateStep() 
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
            
        private void TestCompletion() 
        {
            isFinished = repeatCnt >= 0 && (step > repeatCnt*2 || step < 0);
        }

    }
}