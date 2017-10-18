unit _System_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2;
type

  { TSystem }

  TSystem = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure arraycopy(fbuf: jobject; cont: Integer; tbuf: jobject; start: Integer; off: Integer);
  end;

implementation

{ TSystem }

constructor TSystem.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/lang/System');
end;


destructor TSystem.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TSystem.arraycopy(fbuf: jobject; cont: Integer; tbuf: jobject;
  start: Integer; off: Integer);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetStaticMethodID(FEnv, FClsDef, 'arraycopy', '(Ljava/lang/Object;ILjava/lang/Object;II)V');
  FEnv^^.CallStaticVoidMethodA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [fbuf, cont, tbuf, start, off]));
end;

end.

