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
     * A TweenManager updates all your tweens and timelines at once.
     * Its main interest is that it handles the tween/timeline life-cycles for you,
     * as well as the pooling constraints (if object pooling is enabled).
     *
     * Just give it a bunch of tweens or timelines and call update() periodically,
     * you don't need to care for anything else! Relax and enjoy your animations.
     *
     * based on code by  Aurelien Ribon
     * @see Tween
     * @see Timeline
     */
    public class TweenManager : Object
    {
        // -------------------------------------------------------------------------
        // Static API
        // -------------------------------------------------------------------------

        /**
         * Disables or enables the "auto remove" mode of any tween manager for a
         * particular tween or timeline. This mode is activated by default. The
         * interest of desactivating it is to prevent some tweens or timelines from
         * being automatically removed from a manager once they are finished.
         * Therefore, if you update a manager backwards, the tweens or timelines
         * will be played again, even if they were finished.
         */
        public static void SetAutoRemove(Tween object, bool value) 
        {
		    object.isAutoRemoveEnabled = value;
        }
            
        /**
         * Disables or enables the "auto start" mode of any tween manager for a
         * particular tween or timeline. This mode is activated by default. If it
         * is not enabled, add a tween or timeline to any manager won't start it
         * automatically, and you'll need to call .start() manually on your object.
         */
        public static void SetAutoStart(Tween object, bool value) 
        {
            object.isAutoStartEnabled = value;
        }

        // -------------------------------------------------------------------------
        // Public API
        // -------------------------------------------------------------------------
        public GenericArray<Tweenbase> objects;     
        public bool isPaused = false; 

        public TweenManager()
        {
            Interpolation.Initialize();
            Tween.Init();
            objects = new GenericArray<Tweenbase>(20);
        }

        /**
         * Adds a tween or timeline to the manager and starts or restarts it.
         *
         * @return The manager, for instruction chaining.
         */
        public TweenManager Add(Tweenbase object)
        {
            objects.Add(object);
            if (object.isAutoStartEnabled) 
            {
                object.Start();
            }
            return this;
        }

        /**
         * Returns true if the manager contains any valid interpolation associated
         * to the given target object and to the given tween type.
         */
        public bool ContainsTarget(void* target, int tweenType=-1) 
        {
            for (int i=0, n=objects.length; i<n; i++) 
            {
                Tweenbase obj = objects.Get(i);
                if (obj.ContainsTarget(target, tweenType)) return true;
            }
            return false;
        }

        /**
         * Kills every managed tweens and timelines.
         */
        public void KillAll() 
        {
            for (int i=0, n=objects.length; i<n; i++) 
            {
                var obj = objects.Get(i);
                obj.Kill();
            }
        }

        /**
         * Kills every tweens associated to the given target and tween type. Will
         * also kill every timelines containing a tween associated to the given
         * target and tween type.
         */
        public void KillTarget(void* target, int tweenType=-1) {
            for (int i=0, n=objects.length; i<n; i++) 
            {
                var obj = objects.Get(i);
                obj.KillTarget(target, tweenType);
            }
        }


        /**
         * Pauses the manager. Further update calls won't have any effect.
         */
        public void Pause()
        {
            isPaused = true;
        }

        /**
         * Resumes the manager, if paused.
         */
        public void Resume()
        {
            isPaused = false;
        }

        /**
         * Updates every tweens with a delta time ang handles the tween life-cycles
         * automatically. If a tween is finished, it will be removed from the
         * manager. The delta time represents the elapsed time between now and the
         * last update call. Each tween or timeline manages its local time, and adds
         * this delta to its local time to update itself.
         *
         * Slow motion, fast motion and backward play can be easily achieved by
         * tweaking this delta time. Multiply it by -1 to play the animation
         * backward, or by 0.5 to play it twice slower than its normal speed.
         */
        public void Update(float delta)
        {
            if (objects.length == 0) return;

            if (!isPaused)
                objects.ForEach(it => it.Update(delta));

        }

        /**
         * Gets the number of managed objects. An object may be a tween or a
         * timeline. Note that a timeline only counts for 1 object, since it
         * manages its children itself.
         * 
         * To get the count of running tweens, see {@link GetRunningTweensCount}.
         */
        public int Size() 
        {
            return objects.length;
        }

        /**
         * Gets the number of running tweens. This number includes the tweens
         * located inside timelines (and nested timelin
         * 
         * ''Provided for debug purpose only.''
         */
        public int GetRunningTweensCount() 
        {
            return objects.length;
        }
        // -------------------------------------------------------------------------
        // Helpers
        // -------------------------------------------------------------------------

        
    }
}
