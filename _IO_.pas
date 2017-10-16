unit _IO_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2;
type

  { TDataInputStream }

  TDataInputStream = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure init(Aobj: jobject);
      function readInt(): Integer;
  end;

  { TByteArrayInputStream }

  TByteArrayInputStream = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function NewObj(buff: jbyteArray): jobject;
  end;

implementation

{ TDataInputStream }

constructor TDataInputStream.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/io/DataInputStream');
end;

destructor TDataInputStream.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TDataInputStream.init(Aobj: jobject);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/io/InputStream;)V');
  FOrigin:= FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [Aobj]));
end;

function TDataInputStream.readInt: Integer;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'readInt', '()I');
  Exit(FEnv^^.CallIntMethod(FEnv, FOrigin, m));
end;

{ TByteArrayInputStream }

constructor TByteArrayInputStream.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/io/ByteArrayInputStream');
end;

destructor TByteArrayInputStream.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TByteArrayInputStream.NewObj(buff: jbyteArray): jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '([B)V');
  Exit(FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [buff])));
end;

end.

