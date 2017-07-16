[CCode (cprefix = "", lower_case_cprefix = "")]
namespace MersenneTwister {
	[CCode (cname = "init_genrand", cheader_filename = "mt19937ar.h")]
	public void InitGenrand (ulong s);

	[CCode (cname = "init_by_array", cheader_filename = "mt19937ar.h")]
	public void InitByArray (ulong[] init_key, int key_length);

	[CCode (cname = "genrand_int32", cheader_filename = "mt19937ar.h")]
	public ulong GenrandInt32 ();

	[CCode (cname = "genrand_int31", cheader_filename = "mt19937ar.h")]
	public ulong GenrandInt31 ();

	[CCode (cname = "genrand_real1", cheader_filename = "mt19937ar.h")]
	public double GenrandReal1 ();
    
	[CCode (cname = "genrand_real2", cheader_filename = "mt19937ar.h")]
	public double GenrandReal2 ();

	[CCode (cname = "genrand_real3", cheader_filename = "mt19937ar.h")]
	public double GenrandReal3 ();

	[CCode (cname = "genrand_real53", cheader_filename = "mt19937ar.h")]
	public double GenrandReal53 ();

}

