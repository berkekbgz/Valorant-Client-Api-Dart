class Lockfile {
  String name;
  String pid;
  String port;
  String password;
  Protocol protocol;

  Lockfile({required this.name, required this.pid, required this.port, required this.password, required this.protocol});
}

enum Protocol { http, https }
