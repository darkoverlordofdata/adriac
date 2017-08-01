/**
 * Comoponents
 * 
 * 
 */
namespace Entitas 
{ 
	public struct Transform 
	{
		public Sdx.Math.Vector2? scale;
		public Sdx.Math.Vector2? position;
		public SDL.Video.Rect? aabb;
 		public Sdx.Graphics.Sprite? sprite;

		public Transform(Sdx.Graphics.Sprite sprite) 
		{
			this.sprite = sprite;
			position = { 0, 0 };
			scale = { sprite.scale.x, sprite.scale.y };
			aabb = { 0, 0, sprite.width, sprite.height };
		}
	}


	[SimpleType]
	public struct Layer 
	{
		public int value; 
    }

	[SimpleType, Immutable]
	public struct Show 
	{
		public bool active;
    }

	[SimpleType]
	public struct Tint 
	{
        public int r;
        public int g;
        public int b;
        public int a;
    }

	[SimpleType]
	public struct Velocity 
	{
		public float x; 
		public float y; 
    }

	/**
	 *  Component bit masks
	 */
	const uint64 UNKNOWN		= 0x0000000000000000;
	const uint64 LAYER 			= 0x0000000000000001;
	const uint64 SHOW 			= 0x0000000000000002;
	const uint64 TINT 			= 0x0000000000000004;
	const uint64 VELOCITY 		= 0x0000000000000008;
	const uint64 ACTIVE 		= 0x8000000000000000;

	/**
	* Component names
	*/
	const string[] ComponentString = 
	{
		"Unknown",
		"Layer",
		"Show",
		"Tint",
		"Velocity"
	};

	/**
	* Components
	*/
	public enum Components 
	{
		UnknownComponent,
		LayerComponent,
		ShowComponent,
		TintComponent,
		VelocityComponent
    }
}
