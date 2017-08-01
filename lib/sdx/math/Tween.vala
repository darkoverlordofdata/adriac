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
    /**
     * Core class of the Tween Engine. A Tween is basically an interpolation
     * between two values of an object attribute. However, the main interest of a
     * Tween is that you can apply an easing formula on this interpolation, in
     * order to smooth the transitions or to achieve cool effects like springs or
     * bounces.
     * <p/>
     *
     * The Universal Tween Engine is called "universal" because it is able to apply
     * interpolations on every attribute from every possible object. Therefore,
     * every object in your application can be animated with cool effects: it does
     * not matter if your application is a game, a desktop interface or even a
     * console program! If it makes sense to animate something, then it can be
     * animated through this engine.
     * <p/>
     *
     * This class contains many static factory methods to create and instantiate
     * new interpolations easily. The common way to create a Tween is by using one
     * of these factories:
     * <p/>
     *
     * - Tween.to(...)<br/>
     * - Tween.from(...)<br/>
     * - Tween.set(...)<br/>
     * - Tween.call(...)
     * <p/>
     *
     * <h2>Example - firing a Tween</h2>
     *
     * The following example will move the target horizontal position from its
     * current value to x=200 and y=300, during 500ms, but only after a delay of
     * 1000ms. The animation will also be repeated 2 times (the starting position
     * is registered at the end of the delay, so the animation will automatically
     * restart from this registered position).
     * <p/>
     *
     * {{{
     * Tween.to(myObject, POSITION_XY, 0.5f)
     *      .target(200, 300)
     *      .ease(Quad.INOUT)
     *      .delay(1.0f)
     *      .repeat(2, 0.2f)
     *      .start(myManager);
     * }}}
     *
     * Tween life-cycles can be automatically managed for you, thanks to the
     * {link TweenManager} class. If you choose to manage your tween when you start
     * it, then you don't need to care about it anymore. <b>Tweens are
     * <i>fire-and-forget</i>: don't think about them anymore once you started
     * them (if they are managed of course).</b>
     * <p/>
     *
     * You need to periodicaly update the tween engine, in order to compute the new
     * values. If your tweens are managed, only update the manager; else you need
     * to call {link #update()} on your tweens periodically.
     * <p/>
     *
     * <h2>Example - setting up the engine</h2>
     *
     * The engine cannot directly change your objects attributes, since it doesn't
     * know them. Therefore, you need to tell him how to get and set the different
     * attributes of your objects: <b>you need to implement the {link
     * TweenAccessor} interface for each object class you will animate</b>. Once
     * done, don't forget to register these implementations, using the static method
     * {link registerAccessor()}, when you start your application.
     *
     * author Aurelien Ribon
     * @see TweenAccessor
     * @see TweenManager
     * @see TweenEquation
     * @see Timeline
     */
    public class Tween : Tweenbase
    {
        // -------------------------------------------------------------------------
        // Static -- misc
        // -------------------------------------------------------------------------

        public static void Init()
        {
            pool = new Stack<Tween>();
            registeredAccessors = new HashTable<void*,TweenAccessor>(null, null);
        }

        /**
         * Used as parameter in {link #repeat(int, float)} and
         * {link #repeatYoyo(int, float)} methods.
         */
        public const int INFINITY = -1;
        
        public static int combinedAttrsLimit = 3;
        public static int waypointsLimit = 0;
        /**
         * Changes the limit for combined attributes. Defaults to 3 to reduce
         * memory footprint.
         */
        public static void SetCombinedAttributesLimit(int limit) 
        {
            combinedAttrsLimit = limit;
        }

        
        /**
         * Changes the limit of allowed waypoints for each tween. Defaults to 0 to
         * reduce memory footprint.
         */
        public static void SetWaypointsLimit(int limit) 
        {
            waypointsLimit = limit;
        }

        
        // -------------------------------------------------------------------------
        // Static -- tween accessors
        // -------------------------------------------------------------------------

        /**
         * Registers an accessor with the class of an object. This accessor will be
         * used by tweens applied to every objects implementing the registered
         * class, or inheriting from it.
         *
         * @param someClass An object class.
         * @param defaultAccessor The accessor that will be used to tween any
         * object of klass "someClass".x`
         */
        public static void RegisterAccessor(void* someClass, TweenAccessor defaultAccessor)
        {
            registeredAccessors.Set(someClass, defaultAccessor);
        }


        /**
         * Gets the registered TweenAccessor associated with the given object class.
         *
         * @param someClass An object class.
         */
        public static TweenAccessor GetRegisteredAccessor(void* someClass) 
        {
            return registeredAccessors.Get(someClass);
        }

        // -------------------------------------------------------------------------
        // Static -- factories
        // -------------------------------------------------------------------------

        /**
         * Factory creating a new standard interpolation. This is the most common
         * type of interpolation. The starting values are retrieved automatically
         * after the delay (if any).
         * <br/><br/>
         *
         * <b>You need to set the target values of the interpolation by using one
         * of the target() methods</b>. The interpolation will run from the
         * starting values to these target values.
         * <br/><br/>
         *
         * The common use of Tweens is "fire-and-forget": you do not need to care
         * for tweens once you added them to a TweenManager, they will be updated
         * automatically, and cleaned once finished. Common call:
         * <br/><br/>
         *
         * {{{
         * Tween.to(myObject, POSITION, 1.0f)
         *      .target(50, 70)
         *      .ease(Quad.INOUT)
         *      .start(myManager);
         * }}}
         *
         * Several options such as delay, repetitions and callbacks can be added to
         * the tween.
         *
         * @param target The target object of the interpolation.
         * @param tweenType The desired type of interpolation.
         * @param duration The duration of the interpolation, in milliseconds.
         * @return The generated Tween.
         */
        public static Tween To(void* target, int tweenType, float duration) 
        {
            var tween = pool.IsEmpty() ? new Tween() : (Tween)pool.Pop().Reset();
            tween.Setup(target, tweenType, duration);
            tween.Ease(Interpolation.quadInOut);
            return tween;
        }

        /**
         * Factory creating a new reversed interpolation. The ending values are
         * retrieved automatically after the delay (if any).
         * <br/><br/>
         *
         * <b>You need to set the starting values of the interpolation by using one
         * of the target() methods</b>. The interpolation will run from the
         * starting values to these target values.
         * <br/><br/>
         *
         * The common use of Tweens is "fire-and-forget": you do not need to care
         * for tweens once you added them to a TweenManager, they will be updated
         * automatically, and cleaned once finished. Common call:
         * <br/><br/>
         *
         * {{{
         * Tween.from(myObject, POSITION, 1.0f)
         *      .target(0, 0)
         *      .ease(Quad.INOUT)
         *      .start(myManager);
         * }}}
         *
         * Several options such as delay, repetitions and callbacks can be added to
         * the tween.
         *
         * @param target The target object of the interpolation.
         * @param tweenType The desired type of interpolation.
         * @param duration The duration of the interpolation, in milliseconds.
         * @return The generated Tween.
         */
        public static Tween From(void* target, int tweenType, float duration) 
        {
            var tween = pool.IsEmpty() ? new Tween() : (Tween)pool.Pop().Reset();
            tween.Setup(target, tweenType, duration);
            tween.Ease(Interpolation.quadInOut);
            tween.isFrom = true;
            return tween;
        }

        /**
         * Factory creating a new instantaneous interpolation (thus this is not
         * really an interpolation).
         * <br/><br/>
         *
         * <b>You need to set the target values of the interpolation by using one
         * of the target() methods</b>. The interpolation will set the target
         * attribute to these values after the delay (if any).
         * <br/><br/>
         *
         * The common use of Tweens is "fire-and-forget": you do not need to care
         * for tweens once you added them to a TweenManager, they will be updated
         * automatically, and cleaned once finished. Common call:
         * <br/><br/>
         *
         * {{{
         * Tween.set(myObject, POSITION)
         *      .target(50, 70)
         *      .delay(1.0f)
         *      .start(myManager);
         * }}}
         *
         * Several options such as delay, repetitions and callbacks can be added to
         * the tween.
         *
         * @param target The target object of the interpolation.
         * @param tweenType The desired type of interpolation.
         * @return The generated Tween.
         */
        public static Tween Set(void* target, int tweenType)
        {
            var tween = pool.IsEmpty() ? new Tween() : (Tween)pool.Pop().Reset();
            tween.Setup(target, tweenType, 0);
            tween.Ease(Interpolation.quadInOut);
            return tween;
        }

        /**
         * Factory creating a new timer. The given callback will be triggered on
         * each iteration start, after the delay.
         * <br/><br/>
         *
         * The common use of Tweens is "fire-and-forget": you do not need to care
         * for tweens once you added them to a TweenManager, they will be updated
         * automatically, and cleaned once finished. Common call:
         * <br/><br/>
         *
         * {{{
         * Tween.call(myCallback)
         *      .delay(1.0f)
         *      .repeat(10, 1000)
         *      .start(myManager);
         * }}}
         *
         * @param callback The callback that will be triggered on each iteration
         * start.
         * @return The generated Tween.
         * @see TweenCallback
         */
        public static Tween Call(TweenCallbackOnEvent callback)
        {
            var tween = pool.IsEmpty() ? new Tween() : (Tween)pool.Pop().Reset();
            tween.Setup(null, -1, 0);
            tween.SetCallback(callback);
		    tween.SetCallbackTriggers(TweenCallback.START);
            return tween;
        }

        /**
         * Convenience method to create an empty tween. Such object is only useful
         * when placed inside animation sequences (see {link Timeline}), in which
         * it may act as a beacon, so you can set a callback on it in order to
         * trigger some action at the right moment.
         *
         * @return The generated Tween.
         * @see Timeline
         */
        public static Tween Mark()
        {
            var tween = pool.IsEmpty() ? new Tween() : (Tween)pool.Pop().Reset();
            tween.Setup(null, -1, 0);
            return tween;
        }

        // -------------------------------------------------------------------------
        // Setup
        // -------------------------------------------------------------------------
        public Tween()
        {
            base();
            kind = TweenKind.TWEEN;
            Overrides();
            Reset();

        }

        public void Setup(void* target, int tweenType, float duration)
        {
		    if (duration < 0) throw new Exception.RuntimeException("Duration can't be negative");
            this.target = target;
            var tweenable = (Klass)target;
            targetClass = tweenable.klass;
            this.type = tweenType;
            this.duration = duration;
        }


        // -------------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------------

        /**
         * Sets the easing equation of the tween. Existing equations are located in
         * <i>aurelienribon.tweenengine.equations</i> package, but you can of course
         * implement your owns, see {link TweenEquation}. You can also use the
         * {link TweenEquations} static instances to quickly access all the
         * equations. Default equation is Quad.INOUT.
         * <p/>
         *
         * <b>Proposed equations are:</b><br/>
         * - Linear.INOUT,<br/>
         * - Quad.IN | OUT | INOUT,<br/>
         * - Cubic.IN | OUT | INOUT,<br/>
         * - Quart.IN | OUT | INOUT,<br/>
         * - Quint.IN | OUT | INOUT,<br/>
         * - Circ.IN | OUT | INOUT,<br/>
         * - Sine.IN | OUT | INOUT,<br/>
         * - Expo.IN | OUT | INOUT,<br/>
         * - Back.IN | OUT | INOUT,<br/>
         * - Bounce.IN | OUT | INOUT,<br/>
         * - Elastic.IN | OUT | INOUT
         *
         * @return The current tween, for chaining instructions.
         * @see TweenEquation
         * @see TweenEquations
         */
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
        
        // -------------------------------------------------------------------------
        // Overrides
        // -------------------------------------------------------------------------
        public void Overrides()
        {
            var Reset_ = Reset;
            Reset = () => 
            {
                Reset_();
                target = null;
                targetClass = null;
                accessor = null;
                type = -1;
                equation = null;

                isFrom = isRelative = false;
                combinedAttrsCnt = waypointsCnt = 0;
                if (accessorBuffer.length != combinedAttrsLimit) {
                    accessorBuffer = new float[combinedAttrsLimit];
                }
                return this;
            };

            Build = () =>
            {
                if (target == null) return this;
                accessor = registeredAccessors.Get(targetClass);
                if (accessor != null) 
                    combinedAttrsCnt = accessor.GetValues(target, type, ref accessorBuffer);
                else
                    throw new Exception.RuntimeException("No TweenAccessor was found for the target");

                if (combinedAttrsCnt > combinedAttrsLimit) 
                    throw new Exception.IllegalArgumentException("CombinedAttrsLimitReached");
                return this;
            };

            InitializeOverride = () => 
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
            };
            
            UpdateOverride = (step, lastStep, isIterationStep, delta) => 
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

            };
            
            ForceStartValues = () => 
            {
                if (target == null) return;
                accessor.SetValues(target, type, ref startValues);
            };

            ForceEndValues = () => 
            {
                if (target == null) return;
                accessor.SetValues(target, type, ref targetValues);
            };


            ContainsTarget = (target, tweenType) =>
            {
                return tweenType < 0
                    ? this.target == target
                    : this.target == target && this.type == tweenType;
            };

        }
    }
}