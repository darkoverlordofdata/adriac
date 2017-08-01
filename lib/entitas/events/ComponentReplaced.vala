/* ******************************************************************************
 *# MIT License
 *
 * Copyright (c) 2015-2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
namespace Entitas.Event
{
    public delegate void OnComponentReplaced(Entity* e, int index, void* component, void* replacement);
    
    public class ComponentReplaced : Object 
    {
        public class Listener : Object 
        {
            public OnComponentReplaced event;
            public Listener(OnComponentReplaced event)
            {
                this.event = event;
            }
        }
        public GenericArray<Listener> listeners;
        public ComponentReplaced() 
        {
            listeners = new GenericArray<Listener>();
        }

        public void Add(OnComponentReplaced event) 
        {
            listeners.Add(new Listener(event));
        }

        public void Remove(OnComponentReplaced event)
        {
            for (var i=0; i<listeners.length; i++) 
            {
                if (listeners.Get(i).event == event) 
                {
                    listeners.RemoveFast(i);
                    return;
                }
            }
        }
        public void Clear()
        {
            listeners.RemoveRange(0, listeners.length);
        }

        public void Dispatch(Entity* e, int index,  void* component, void* replacement)
        {
            listeners.ForEach(listener => listener.event(e, index, component, replacement));
        }
    }
}
