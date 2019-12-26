(* Thundermaker v0.9 *)
(* 2019 (c) saahriktu *)
(* under GNU GPLv3 *)
program thundermaker;
var
	libmode_flg: Boolean = False;

(* check the variable and set default if required *)
procedure put_vrbl_cndtst(vrblnm: String; vrbldflt: String; thisiscmd: Boolean);
begin
	if thisiscmd = True then writeln('ifeq ($(shell which $(', vrblnm, ')),)')
	else writeln('ifeq ($(', vrblnm, '),)');
	writeln(#9, vrblnm, '=', vrbldflt);
	writeln('endif');
end;

(* put the makefile header *)
procedure put_makefile_header();
begin
	put_vrbl_cndtst('prefix', '/usr/local', False);
	put_vrbl_cndtst('datadir', '$(prefix)/share', False);
end;

(* c/c++ definitions and compilations *)
procedure c_and_cpp_lang_start(libmode: Boolean; cmplrvar: String; cmplrstr: String; srcext: String; extflagsvar: String);
begin
	put_makefile_header();
	put_vrbl_cndtst(cmplrvar, cmplrstr, True);
	if libmode = True then put_vrbl_cndtst('libdir', '$(prefix)/lib', False);
	writeln('all:');
	if libmode = True then begin
		write(#9'$(', cmplrvar,') -c -fPIC $(', extflagsvar);
		writeln(') -o ', ParamStr(2), '.o ', ParamStr(2), srcext);
		write(#9'$(', cmplrvar,') -fPIC -shared $(', extflagsvar);
		writeln(') -o lib', ParamStr(2), '.so ', ParamStr(2), '.o');
	end else writeln(#9'$(', cmplrvar, ') $(', extflagsvar,') -o ', ParamStr(2), ' ', ParamStr(2), srcext);
	if libmode = True then writeln(#9'strip -S lib', ParamStr(2), '.so')
	else writeln(#9'strip -S ', ParamStr(2));
end;

(* pascal definitions and compilations *)
procedure pas_lang_start();
begin
	put_makefile_header();
	put_vrbl_cndtst('PC', 'fpc', True);
	put_vrbl_cndtst('PFLAGS', '-XX -Xg -Xs', False);
	writeln('all:');
	writeln(#9'$(PC) $(PFLAGS) ', ParamStr(2), '.pas');
end;

(* how to install header of library *)
procedure put_install_header(prjname: String; hdrext: String);
begin
			write(#9'install -m644 ', prjname);
			writeln(hdrext, ' $(DESTDIR)$(prefix)/include/', prjname);
end;

(* required directory checking *)
procedure chk_dir_for_install(drpath: String);
begin
		write(#9'if [ ! -d "', drpath,'" ]; then ');
		writeln('mkdir -p ', drpath,'; fi');
end;

begin
	(* initialization *)
	if ParamCount < 2 then begin
		writeln('usage: thundermaker c/c++/pas name [lib]');
		exit;
	end;
	if (ParamCount > 2) then if ParamStr(3) = 'lib' then begin
		libmode_flg := True;
		if ParamStr(1) = 'pas' then begin
			writeln('Error: unsupported mode');
			exit;
		end;
	end;
	(* language switch *)
	case (lowercase(ParamStr(1))) of
	'c': c_and_cpp_lang_start(libmode_flg, 'CC', 'gcc', '.c', 'CFLAGS');
	'c++': c_and_cpp_lang_start(libmode_flg, 'CXX', 'g++', '.cpp', 'CXXFLAGS');
	'pas': pas_lang_start();
       	else writeln('Error: unsupported programming language');
	     exit;
	end;
	(* second part (install: and clean:) *)
	writeln('install:');
	if libmode_flg = True then begin
		chk_dir_for_install('$(DESTDIR)$(libdir)');
		chk_dir_for_install('$(DESTDIR)$(prefix)/include/' + ParamStr(2));
        	write(#9'install -m755 lib', ParamStr(2));
		writeln('.so $(DESTDIR)$(libdir)');
        	if ParamStr(1) = 'c++' then put_install_header(ParamStr(2), '.hpp')
		else put_install_header(ParamStr(2), '.h');
	end else begin
		chk_dir_for_install('$(DESTDIR)$(prefix)/bin');
		writeln(#9'install -m755 ', ParamStr(2), ' $(DESTDIR)$(prefix)/bin');
	end;
	writeln('clean:');
        if ParamStr(1) = 'pas' then writeln(#9'rm ', ParamStr(2), ' ', ParamStr(2), '.dbg ', ParamStr(2), '.o')
	else if libmode_flg = True then writeln(#9'rm ', ParamStr(2), '.o lib', ParamStr(2), '.so')
	     else writeln(#9'rm ', ParamStr(2));
end.
