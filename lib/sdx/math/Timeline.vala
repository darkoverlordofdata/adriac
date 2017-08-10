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
     * A Timeline can be used to create complex animations made of sequences and
     * parallel sets of Tweens.
     *
     * The following example will create an animation sequence composed of 5 parts:
     *
     *  1. First, opacity and scale are set to 0 (with Tween.set() calls).
     *  1. Then, opacity and scale are animated in parallel.
     *  1. Then, the animation is paused for 1s.
     *  1. Then, position is animated to x=100.
     *  1. Then, rotation is animated to 360°.
     *
     * This animation will be repeated 5 times, with a 500ms delay between each
     * iteration:
     *
     * {{{
     * Timeline.CreateSequence()
     *     .Push(Tween.Set(myObject, OPACITY).Target({ 0 }))
     *     .Push(Tween.Set(myObject, SCALE).Target({ 0, 0 }))
     *     .BeginParallel()
     *          .Push(Tween.To(myObject, OPACITY, 0.5f).Target({ 1 }).Ease(Interpolation.QuadInOut))
     *          .Push(Tween.To(myObject, SCALE, 0.5f).Target({ 1, 1 }).Ease(Interpolation.QuadInOut))
     *     .End()
     *     .PushPause(1.0f)
     *     .Push(Tween.To(myObject, POSITION_X, 0.5f).Target({ 100 }).Ease(Interpolation.QuadInOut))
     *     .Push(Tween.To(myObject, ROTATION, 0.5f).Target({ 360 }).Ease(Interpolation.QuadInOut))
     *     .Repeat(5, 0.5f)
     *     .Start(myManager);
     * }}}
     *
     * based on code by  Aurelien Ribon 
     * @see Tween
     * @see TweenManager
     * @see Tweenbase.TweenCallback
     */
    public class Timeline : Tweenbase
    {
        // -------------------------------------------------------------------------
        // Static -- factories
        // -------------------------------------------------------------------------

        /**
         * Creates a new timeline with a 'sequence' behavior. Its children will
         * be delayed so that they are triggered one after the other.
         */
        public static Timeline CreateSequence() 
        {
            var tl = pool.IsEmpty() ? new Timeline() : (Timeline)pool.Pop().Reset();
            tl.Setup(TimelineModes.SEQUENCE);
            return tl;
        }
        
        /**
         * Creates a new timeline with a 'parallel' behavior. Its children will be
         * triggered all at once.
         */
        public static Timeline CreateParallel() {
            var tl = pool.IsEmpty() ? new Timeline() : (Timeline)pool.Pop().Reset();
            tl.Setup(TimelineModes.PARALLEL);
            return tl;
        }


        // -------------------------------------------------------------------------
        // Setup
        // -------------------------------------------------------------------------

        private Timeline()
        {
            base();
            kind = TweenKind.TIMELINE;
            Overrides();
            Reset();
        }

        protected void Setup(TimelineModes mode) 
        {
            this.mode = mode;
            this.current = this;
        }

        // -------------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------------

        /**
         * Adds a Tween to the current timeline.
         * Nests a Timeline in the current one.
         *
         * @return The current timeline, for chaining instructions.
         */
        public Timeline Push(Tween tween) {
            if (isBuilt) throw new Exception.RuntimeException("You can't push anything to a timeline once it is started");
            if (kind == TweenKind.TIMELINE)
            {
                if (tween.current != tween) 
                    throw new Exception.RuntimeException("You forgot to call a few 'end()' statements in your pushed timeline");
                tween.parent = current;
            }
            current.children.Add(tween);
            return this;
        }

        /**
         * Adds a pause to the timeline. The pause may be negative if you want to
         * overlap the preceding and following children.
         *
         * @param time A positive or negative duration.
         * @return The current timeline, for chaining instructions.
         */
        public Timeline PushPause(float time) {
            if (isBuilt) throw new Exception.RuntimeException("You can't push anything to a timeline once it is started");
            current.children.Add(Tween.Mark().Delay(time));
            return this;
        }

        /**
         * Starts a nested timeline with a 'sequence' behavior. Don't forget to
         * call {@link End} to close this nested timeline.
         *
         * @return The current timeline, for chaining instructions.
         */
        public Timeline BeginSequence() {
            if (isBuilt) throw new Exception.RuntimeException("You can't push anything to a timeline once it is started");
            var tl = pool.IsEmpty() ? new Timeline() : (Timeline)pool.Pop().Reset();
            tl.parent = current;
            tl.mode = TimelineModes.SEQUENCE;
            current.children.Add(tl);
            current = tl;
            return this;
        }

        /**
         * Starts a nested timeline with a 'parallel' behavior. Don't forget to
         * call {@link End} to close this nested timeline.
         *
         * @return The current timeline, for chaining instructions.
         */
        public Timeline BeginParallel() {
            if (isBuilt) throw new Exception.RuntimeException("You can't push anything to a timeline once it is started");
            var tl = pool.IsEmpty() ? new Timeline() : (Timeline)pool.Pop().Reset();
            tl.parent = current;
            tl.mode = TimelineModes.PARALLEL;
            current.children.Add(tl);
            current = tl;
            return this;
        }

        /**
         * Closes the last nested timeline.
         *
         * @return The current timeline, for chaining instructions.
         */
        public Timeline End() {
            if (isBuilt) throw new Exception.RuntimeException("You can't push anything to a timeline once it is started");
            if (current == this) throw new Exception.RuntimeException("Nothing to end...");
            current = current.parent;
            return this;
        }

        /**
         * Gets a list of the timeline children. If the timeline is started, the
         * list will be immutable.
         */
        public GenericArray<Tweenbase> GetChildren() {
            //  if (isBuilt) return Collections.unmodifiableList(current.children);
            //  else return current.children;
            return current.children;            
        }

        // -------------------------------------------------------------------------
        // Overrides
        // -------------------------------------------------------------------------
        private void Overrides()
        {
            var Reset_ = Reset;
            var Start_ = Start;
            Reset = () => 
            {
                Reset_();
                children = new GenericArray<Timeline>();
                current = parent = null;

                isBuilt = false;
                return this;
            };
        
            Build = () =>
            {
                if (isBuilt) return this;

                duration = 0;

                for (int i=0; i<children.length; i++) 
                {
                    var obj = children.Get(i);

                    if (obj.GetRepeatCount() < 0) throw new Exception.RuntimeException("You can't push an object with infinite repetitions in a timeline");
                    obj.Build();

                    switch (mode) 
                    {
                        case TimelineModes.SEQUENCE:
                            float tDelay = duration;
                            duration += obj.GetFullDuration();
                            obj.delay += tDelay;
                            break;

                        case TimelineModes.PARALLEL:
                            duration = GLib.Math.fmaxf(duration, obj.GetFullDuration());
                            break;
                    }
                }

                isBuilt = true;
                return this;

            };

            Start = () =>
            {
                Start_();

                for (int i=0; i<children.length; i++)
                {
                    var obj = children.Get(i);
                    obj.Start();
                }

                return this;
            };

            Free = () =>
            {
                for (int i=children.length-1; i>=0; i--) 
                {
                    var obj = children.Get(i);
                    children.RemoveIndex(i);
                    obj.Free();
                }

                //  pool.free(this);
            };

            UpdateOverride = (step, lastStep, isIterationStep, delta) =>
            {
                if (!isIterationStep && step > lastStep) {
                    assert(delta >= 0);
                    float dt = IsReverse(lastStep) ? -delta-1 : delta+1;
                    for (int i=0, n=children.length; i<n; i++) children.Get(i).Update(dt);
                    return;
                }

                if (!isIterationStep && step < lastStep) {
                    assert(delta <= 0);
                    float dt = IsReverse(lastStep) ? -delta-1 : delta+1;
                    for (int i=children.length-1; i>=0; i--) children.Get(i).Update(dt);
                    return;
                }

                assert(isIterationStep);

                if (step > lastStep) {
                    if (IsReverse(step)) {
                        ForceEndValues();
                        for (int i=0, n=children.length; i<n; i++) children.Get(i).Update(delta);
                    } else {
                        ForceStartValues();
                        for (int i=0, n=children.length; i<n; i++) children.Get(i).Update(delta);
                    }

                } else if (step < lastStep) {
                    if (IsReverse(step)) {
                        ForceStartValues();
                        for (int i=children.length-1; i>=0; i--) children.Get(i).Update(delta);
                    } else {
                        ForceEndValues();
                        for (int i=children.length-1; i>=0; i--) children.Get(i).Update(delta);
                    }

                } else {
                    float dt = IsReverse(step) ? -delta : delta;
                    if (delta >= 0) for (int i=0, n=children.length; i<n; i++) children.Get(i).Update(dt);
                    else for (int i=children.length-1; i>=0; i--) children.Get(i).Update(dt);
                }

            };

            // -------------------------------------------------------------------------
            // BaseTween impl.
            // -------------------------------------------------------------------------
            ForceStartValues = () =>
            {
                for (int i=children.length-1; i>=0; i--) {
                    var obj = children.Get(i);
                    obj.ForceToStart();
                }
            };

            ForceEndValues = () =>
            {
                for (int i=0, n=children.length; i<n; i++) {
                    var obj = children.Get(i);
                    obj.ForceToEnd(duration);
                }
            };

            ContainsTarget = (target, tweenType) =>
            {
                for (int i=0, n=children.length; i<n; i++) {
                    var obj = children.Get(i);
                    if (obj.ContainsTarget(target, tweenType)) return true;
                }
                return false;
            };

        }
    }
}