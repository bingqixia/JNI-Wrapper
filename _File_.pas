unit _File_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2;
type

  { TFileOutputStream }

  TFileOutputStream = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure init(Aobj: jobject);
      procedure write(buffer: jbyteArray; byteOffset: Integer; byteCount: Integer);
      procedure close();
  end;

  { TFile }

  TFile = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function NewObj(fileName: jstring): jobject;
  end;

implementation

{ TFileOutputStream }

constructor TFileOutputStream.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/io/FileOutputStream');
end;

destructor TFileOutputStream.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TFileOutputStream.init(Aobj: jobject);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/io/File;)V');
  FOrigin:= FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [Aobj]));
end;

procedure TFileOutputStream.write(buffer: jbyteArray; byteOffset: Integer;
  byteCount: Integer);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'write', '([BII)V');
  FEnv^^.CallVoidMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [buffer, byteOffset, byteCount]));
end;

procedure TFileOutputStream.close;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'close', '()V');
  FEnv^^.CallVoidMethod(FEnv, FOrigin, m);
end;

{ TFile }

constructor TFile.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/io/File');
end;

destructor TFile.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TFile.NewObj(fileName: jstring): jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/lang/String;)V');
  Exit(FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [fileName])));
end;

end.

