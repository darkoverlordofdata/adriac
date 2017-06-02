
namespace sdx.files {

	public FileHandle getHandle(string path, FileType type) {
		return new FileHandle(path, type);
	}

	public FileHandle resource(string path) {
		return new FileHandle(path, FileType.Resource);
	}

	public FileHandle asset(string path) {
		return new FileHandle(path, FileType.Asset);
	}

	public FileHandle absolute(string path) {
		return new FileHandle(path, FileType.Absolute);
	}

	public FileHandle relative(string path) {
		return new FileHandle(path, FileType.Relative);
	}
}