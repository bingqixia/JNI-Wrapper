library wrapper;

{$mode objfpc}{$H+}

uses
  {$IFNDEF WINDOWS}
  cthreads,
  {$ENDIF}
  Classes, sysutils, _context_, JNI2, _ActivityThread_, _ClassLoader_,
  _Application_, _ZipFile_, _File_, _System_, _IO_;

procedure Java_com_sample_Sample_test(env: PJNIEnv; obj: jobject; ctx: jobject); stdcall;
var
  c: TContext;
begin
  c := TContext.Create(env, ctx);
  // c.getPackageManager();
  // c.getPackageName();
end;

exports
  Java_com_sample_Sample_test;

begin


end.

