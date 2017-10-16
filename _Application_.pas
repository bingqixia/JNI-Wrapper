unit _Application_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2;
type

  { TInstrumentation }

  TInstrumentation = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function newObj(): jobject;
  end;

  { TApplication }

  TApplication = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure onCreate();
  end;

implementation

{ TInstrumentation }

constructor TInstrumentation.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/Instrumentation');
end;

destructor TInstrumentation.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TInstrumentation.newObj: jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '()V');
  Exit(FEnv^^.NewObject(FEnv, FClsDef, m));
end;

constructor TApplication.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/Application');
end;

destructor TApplication.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TApplication.onCreate;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'onCreate', '()V');
  FEnv^^.CallVoidMethod(FEnv, FOrigin, m);
end;

end.

