unit _ZipFile_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2;
type

  { TBufferedInputStream }

  TBufferedInputStream = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure init(Aobj: jobject);
      function read(buffer: jbyteArray; byteOffset: Integer; byteCount: Integer): Integer;
  end;

  { TZipEntry }

  TZipEntry = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function getName(): jstring;
      function getSize(): jlong;
  end;

  { TEnumeration }

  TEnumeration = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function hasMoreElements(): jboolean;
      function nextElement(): jobject;
  end;

  { TZipFile }

  TZipFile = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure init(fileName: jstring);
      function entries(): TEnumeration;
      function getInputStream(Aobj: jobject): jobject;
  end;

implementation

{ TBufferedInputStream }

constructor TBufferedInputStream.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/io/BufferedInputStream');
end;

destructor TBufferedInputStream.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TBufferedInputStream.init(Aobj: jobject);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/io/InputStream;)V');
  FOrigin:= FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [Aobj]));
end;

function TBufferedInputStream.read(buffer: jbyteArray; byteOffset: Integer;
  byteCount: Integer): Integer;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'read', '([BII)I');
  Exit(FEnv^^.CallIntMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [buffer, byteOffset, byteCount])));
end;

{ TZipEntry }

constructor TZipEntry.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/zip/ZipEntry');
end;

destructor TZipEntry.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TZipEntry.getName: jstring;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getName', '()Ljava/lang/String;');
  Exit(jstring(FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

function TZipEntry.getSize: jlong;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getSize', '()J');
  Exit(FEnv^^.CallLongMethod(FEnv, FOrigin, m));
end;

{ TEnumeration }

constructor TEnumeration.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/Enumeration');
end;

destructor TEnumeration.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TEnumeration.hasMoreElements: jboolean;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'hasMoreElements', '()Z');
  Exit(FEnv^^.CallBooleanMethod(FEnv, FOrigin, m));
end;

function TEnumeration.nextElement: jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'nextElement', '()Ljava/lang/Object;');
  Exit(FEnv^^.CallObjectMethod(FEnv, FOrigin, m));
end;

{ TZipFile }

constructor TZipFile.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/zip/ZipFile');
end;

destructor TZipFile.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TZipFile.init(fileName: jstring);
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/lang/String;)V');
  FOrigin:= FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [fileName]));
end;

function TZipFile.entries: TEnumeration;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'entries', '()Ljava/util/Enumeration;');
  Exit(TEnumeration.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

function TZipFile.getInputStream(Aobj: jobject): jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getInputStream', '(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;');
  Exit(FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [Aobj])));
end;

end.

