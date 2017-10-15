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
/**
 * Sdx Math
 * 
 * Gemometry, Vectors, Movement
 */
namespace  Sdx.Math 
{
    /** 
     * Takes a linear value in the range of 0-1 and outputs a (usually) non-linear, interpolated value.
     * based on code by  Nathan Sweet & Aurelien Ribon
     */
    public class Interpolation : Object
    {
        /**
         * Merges together formulae from libGDX and Universal Tween Engine
         */
        public enum Kind 
        {
            Linear, Smooth, Smooth2, Smoother,
            Pow, PowIn, PowOut, Sin, SinIn, SinOut,
            Exp, ExpIn, ExpOut, Circle, CircleIn, CircleOut,
            Elastic, ElasticIn, ElasticOut,
            Swing, SwingIn, SwingOut,
            Bounce, BounceIn, BounceOut,
            QuadIn, QuadOut, QuadInOut 
        }
            
        public static Interpolation.Linear linear;
        public static Interpolation.Smooth smooth;
        public static Interpolation.Smooth2 smooth2;
        public static Interpolation.Smoother smoother;

        public static Interpolation.Pow pow2;
        public static Interpolation.PowIn pow2In;
        public static Interpolation.PowOut pow2Out;
        public static Interpolation.Pow pow3;
        public static Interpolation.PowIn pow3In;
        public static Interpolation.PowOut pow3Out;

        public static Interpolation.Pow pow4;
        public static Interpolation.PowIn pow4In;
        public static Interpolation.PowOut pow4Out;
        public static Interpolation.Pow pow5;
        public static Interpolation.PowIn pow5In;
        public static Interpolation.PowOut pow5Out;

        public static Interpolation.Sin sine;
        public static Interpolation.SinIn sineIn;
        public static Interpolation.SinOut sineOut;
        
        public static Interpolation.Exp exp10;
        public static Interpolation.ExpIn exp10In;
        public static Interpolation.ExpOut exp10Out;

        public static Interpolation.Exp exp5;
        public static Interpolation.ExpIn exp5In;
        public static Interpolation.ExpOut exp5Out;

        public static Interpolation.Circle circle;
        public static Interpolation.CircleIn circleIn;
        public static Interpolation.CircleOut circleOut;

        public static Interpolation.Elastic elastic;
        public static Interpolation.ElasticIn elasticIn;
        public static Interpolation.ElasticOut elasticOut;

        public static Interpolation.Swing swing;
        public static Interpolation.SwingIn swingIn;
        public static Interpolation.SwingOut swingOut;

        public static Interpolation.Bounce bounce;
        public static Interpolation.BounceIn bounceIn;
        public static Interpolation.BounceOut bounceOut;

        public static Interpolation.QuadIn quadIn;
        public static Interpolation.QuadOut quadOut;
        public static Interpolation.QuadInOut quadInOut;

        public delegate float InterpolationApply(float a);

        public InterpolationApply Apply = (a) => { return 0; };

        public static void Initialize()
        {
            linear = new Linear();
            smooth = new Smooth();
            smooth2 = new Smooth2();
            smoother = new Smoother();

            pow2 = new Pow(2);
            pow2In = new PowIn(2);
            pow2Out = new PowOut(2);

            pow3 = new Pow(3);
            pow3In = new PowIn(3);
            pow3Out = new PowOut(3);

            pow4 = new Pow(4);
            pow4In = new PowIn(4);
            pow4Out = new PowOut(4);

            pow5 = new Pow(5);
            pow5In = new PowIn(5);
            pow5Out = new PowOut(5);

            sine = new Sin();
            sineIn = new SinIn();
            sineOut = new SinOut();

            exp10 = new Exp(2, 10);
            exp10In = new ExpIn(2, 10);
            exp10Out = new ExpOut(2, 10);

            exp5 = new Exp(2, 5);
            exp5In = new ExpIn(2, 5);
            exp5Out = new ExpOut(2, 5);

            circle = new Circle();
            circleIn = new CircleIn();
            circleOut = new CircleOut();

            elastic = new Elastic(2, 10, 7, 1);
            elasticIn = new ElasticIn(2, 10, 6, 1);
            elasticOut = new ElasticOut(2, 10, 7, 1);

            swing = new Swing(1.5f);
            swingIn = new SwingIn(2f);
            swingOut = new SwingOut(2f);

            bounce = new Bounce(4);
            bounceIn = new BounceIn(4);
            bounceOut = new BounceOut(4);

            quadIn = new QuadIn();
            quadOut = new QuadOut();
            quadInOut = new QuadInOut();
        }

        
        public class Linear : Interpolation
        {
            public Linear() { Apply = (a) => { return a; }; }
        }
        public class Smooth : Interpolation
        {
            public Smooth() { Apply = (a) => { return a * a * (3 - 2 * a); }; }
        }
        public class Smooth2 : Interpolation
        {
            public Smooth2() 
            { 
                Apply = (a) => 
                { 
                    a = a * a * (3 - 2 * a);
                    return a * a * (3 - 2 * a);
                };
            }
        }

        public class Smoother : Interpolation
        {
            public Smoother() 
            { 
                Apply = (a) => 
                { 
                    return Clamp(a * a * a * (a * (a * 6 - 15) + 10), 0, 1); 
                };
            }
        }

        public class Pow : Interpolation
        {
            public Pow(int power) 
            { 
                Apply = (a) => 
                { 
                    if (a <= 0.5f) return (float)GLib.Math.pow(a * 2, power) / 2;
                    return (float)GLib.Math.pow((a - 1) * 2, power) / (power % 2 == 0 ? -2 : 2) + 1;
                };
            }
        }
        
        public class PowIn : Interpolation
        {
            public PowIn(int power) 
            { 
                Apply = (a) => 
                { 
			        return (float)GLib.Math.pow(a, power);
                };
            }
        }

        public class PowOut : Interpolation
        {
            public PowOut(int power) 
            { 
                Apply = (a) => 
                { 
        			return (float)GLib.Math.pow(a - 1, power) * (power % 2 == 0 ? -1 : 1) + 1;
                };
            }
        }

        public class Sin : Interpolation
        {
            public Sin() 
            { 
                Apply = (a) => 
                { 
			        return (1 - GLib.Math.cosf((float)(a * GLib.Math.PI))) / 2;
                };
            }
        }
        
        public class SinIn : Interpolation
        {
            public SinIn() 
            { 
                Apply = (a) => 
                { 
			        return 1 - GLib.Math.cosf((float)(a * GLib.Math.PI / 2));
                };
            }
        }

        public class SinOut : Interpolation
        {
            public SinOut() 
            { 
                Apply = (a) => 
                { 
        			return GLib.Math.sinf((float)(a * GLib.Math.PI / 2));
                };
            }
        }

        public class Exp : Interpolation
        {
            public Exp(float value, float power) 
            { 
                var min = (float)GLib.Math.pow(value, -power);
                var scale = 1 / (1 - min);

                Apply = (a) => 
                { 
                    if (a <= 0.5f) return ((float)GLib.Math.pow(value, power * (a * 2 - 1)) - min) * scale / 2;
                    return (2 - ((float)GLib.Math.pow(value, -power * (a * 2 - 1)) - min) * scale) / 2;
                };
            }
        }
        
        public class ExpIn : Interpolation
        {
            public ExpIn(float value, float power) 
            { 
                var min = (float)GLib.Math.pow(value, -power);
                var scale = 1 / (1 - min);
                Apply = (a) => 
                { 
    			    return ((float)GLib.Math.pow(value, power * (a - 1)) - min) * scale;
                };
            }
        }
        
        public class ExpOut : Interpolation
        {
            public ExpOut(float value, float power) 
            { 
                var min = (float)GLib.Math.pow(value, -power);
                var scale = 1 / (1 - min);
                Apply = (a) => 
                { 
    			    return 1 - ((float)GLib.Math.pow(value, -power * a) - min) * scale;
                };
            }
        }

        public class Circle : Interpolation
        {
            public Circle() 
            { 
                Apply = (a) => 
                { 
                    if (a <= 0.5f) {
                        a *= 2;
                        return (1 - (float)GLib.Math.sqrt(1 - a * a)) / 2;
                    }
                    a--;
                    a *= 2;
                    return ((float)GLib.Math.sqrt(1 - a * a) + 1) / 2;
                };
            }
        }

        public class CircleIn : Interpolation
        {
            public CircleIn() 
            { 
                Apply = (a) => 
                { 
			        return 1 - (float)GLib.Math.sqrt(1 - a * a);
                };
            }
        }

        public class CircleOut : Interpolation
        {
            public CircleOut() 
            { 
                Apply = (a) => 
                { 
                    a--;
                    return (float)GLib.Math.sqrt(1 - a * a);
                };
            }
        }

        public class Elastic : Interpolation
        {
            public Elastic(float value, float power, int bounce, float scale) 
            { 
			    var bounces = (float)(bounce * GLib.Math.PI * (bounce % 2 == 0 ? 1 : -1));

                Apply = (a) => 
                { 
                    if (a <= 0.5f) {
                        a *= 2;
                        return (float)GLib.Math.pow(value, power * (a - 1)) * GLib.Math.sinf(a * bounces) * scale / 2;
                    }
                    a = 1 - a;
                    a *= 2;
                    return 1 - (float)GLib.Math.pow(value, power * (a - 1)) * GLib.Math.sinf(a * bounces) * scale / 2;
                };
            }
        }
        

        public class ElasticIn : Interpolation
        {
            public ElasticIn(float value, float power, int bounce, float scale) 
            { 
			    var bounces = (float)(bounce * GLib.Math.PI * (bounce % 2 == 0 ? 1 : -1));

                Apply = (a) => 
                { 
                    if (a >= 0.99) return 1;
                    return (float)GLib.Math.pow(value, power * (a - 1)) * GLib.Math.sinf(a * bounces) * scale;
                };
            }
        }


        public class ElasticOut : Interpolation
        {
            public ElasticOut(float value, float power, int bounce, float scale) 
            { 
			    var bounces = (float)(bounce * GLib.Math.PI * (bounce % 2 == 0 ? 1 : -1));

                Apply = (a) => 
                { 
                    if (a == 0) return 0;
                    a = 1 - a;
                    return (1 - (float)GLib.Math.pow(value, power * (a - 1)) * GLib.Math.sinf(a * bounces) * scale);
                };
            }
        }

        public class BounceOut : Interpolation
        {
            public BounceOut(int bounces, float[] w = null, float[] h = null) 
            { 
                if (bounces < 2 || bounces > 5) throw new Exception.IllegalArgumentException("bounces cannot be < 2 or > 5: " + bounces.ToString());
                var widths = new float[bounces];
                var heights = new float[bounces];
                BounceInit(bounces, ref widths, ref heights);

                Apply = (a) => 
                { 
                    return BounceApply(a, ref widths, ref heights);
                };
            }
        }
        
        public class Bounce : Interpolation
        {
            public Bounce(int bounces, float[] w = null, float[] h = null) 
            { 
                if (bounces < 2 || bounces > 5) throw new Exception.IllegalArgumentException("bounces cannot be < 2 or > 5: " + bounces.ToString());
                var widths = new float[bounces];
                var heights = new float[bounces];
                BounceInit(bounces, ref widths, ref heights);


                Apply = (a) => 
                { 
                    InterpolationApply Out = (a) => {
                        var test = a + widths[0] / 2;
                        if (test < widths[0]) return test / (widths[0] / 2) - 1;
                        return BounceApply(a, ref widths, ref heights);
                    };
                    if (a <= 0.5f) return (1 - Out(1 - a * 2)) / 2;
                    return Out(a * 2 - 1) / 2 + 0.5f;
                };
            }
        }
        
        public class BounceIn : Interpolation
        {
            public BounceIn(int bounces, float[] w = null, float[] h = null) 
            { 
                if (bounces < 2 || bounces > 5) throw new Exception.IllegalArgumentException("bounces cannot be < 2 or > 5: " + bounces.ToString());
                var widths = new float[bounces];
                var heights = new float[bounces];
                BounceInit(bounces, ref widths, ref heights);

                Apply = (a) => 
                { 
                    return 1 - BounceApply(1 - a, ref widths, ref heights);
                };
            }
        }

        float BounceApply(float a, ref float[] widths, ref float[] heights) 
        { 
            if (a == 1) return 1;
            a += widths[0] / 2;
            var width = 0f, height = 0f;
            for (int i = 0, n = widths.length; i < n; i++) {
                width = widths[i];
                if (a <= width) {
                    height = heights[i];
                    break;
                }
                a -= width;
            }
            a /= width;
            var z = 4 / width * height * a;
            return 1 - (z - z * a) * width;
                    
        }

        void BounceInit(int bounces, ref float[] widths, ref float[] heights)
        {
            heights[0] = 1;
            switch (bounces) {
            case 2:
                widths[0] = 0.6f;
                widths[1] = 0.4f;
                heights[1] = 0.33f;
                break;
            case 3:
                widths[0] = 0.4f;
                widths[1] = 0.4f;
                widths[2] = 0.2f;
                heights[1] = 0.33f;
                heights[2] = 0.1f;
                break;
            case 4:
                widths[0] = 0.34f;
                widths[1] = 0.34f;
                widths[2] = 0.2f;
                widths[3] = 0.15f;
                heights[1] = 0.26f;
                heights[2] = 0.11f;
                heights[3] = 0.03f;
                break;
            case 5:
                widths[0] = 0.3f;
                widths[1] = 0.3f;
                widths[2] = 0.2f;
                widths[3] = 0.1f;
                widths[4] = 0.1f;
                heights[1] = 0.45f;
                heights[2] = 0.3f;
                heights[3] = 0.15f;
                heights[4] = 0.06f;
                break;
            }
            widths[0] *= 2;

        }

        public class Swing : Interpolation
        {
            public Swing(float scale) 
            { 
                scale = scale * 2;

                Apply = (a) => 
                { 
                    if (a <= 0.5f) {
                        a *= 2;
                        return a * a * ((scale + 1) * a - scale) / 2;
                    }
                    a--;
                    a *= 2;
                    return a * a * ((scale + 1) * a + scale) / 2 + 1;
                };
            }
        }
        
        public class SwingOut : Interpolation
        {
            public SwingOut(float scale) 
            { 
                scale = scale * 2;

                Apply = (a) => 
                { 
                    a--;
                    return a * a * ((scale + 1) * a + scale) + 1;
               };
            }
        }

        
        public class SwingIn : Interpolation
        {
            public SwingIn(float scale) 
            { 
                scale = scale * 2;

                Apply = (a) => 
                { 
			        return a * a * ((scale + 1) * a - scale);
                };
            }
        }

        public class QuadIn : Interpolation
        {
            public QuadIn() 
            { 
                Apply = (a) => 
                { 
                    return a*a;
                };
            }
        }

        public class QuadOut : Interpolation
        {
            public QuadOut() 
            { 
                Apply = (a) => 
                { 
                    return -a*(a-2);
                };
            }
        }

        public class QuadInOut : Interpolation
        {
            public QuadInOut() 
            { 
                Apply = (a) => 
                { 
                    if ((a*=2) < 1) return 0.5f*a*a;
                    a = a-1;
                    return -0.5f * (a*(a-2) - 1);
                };
            }
        }
        
    }
}