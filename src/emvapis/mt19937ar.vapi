[CCode (cprefix = "", lower_case_cprefix = "")]
namespace MersenneTwister {
	[CCode (cheader_filename = "mt19937ar.h")]
	public void init_genrand (ulong s);

	[CCode (cheader_filename = "mt19937ar.h")]
	public void init_by_array (ulong[] init_key, int key_length);

	[CCode (cheader_filename = "mt19937ar.h")]
	public ulong genrand_int32 ();

	[CCode (cheader_filename = "mt19937ar.h")]
	public ulong genrand_int31 ();

	[CCode (cheader_filename = "mt19937ar.h")]
	public double genrand_real1 ();
    
	[CCode (cheader_filename = "mt19937ar.h")]
	public double genrand_real2 ();

	[CCode (cheader_filename = "mt19937ar.h")]
	public double genrand_real3 ();

	[CCode (cheader_filename = "mt19937ar.h")]
	public double genrand_real53 ();

}

