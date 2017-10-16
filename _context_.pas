unit _context_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2, android;

type

  { TPackageInfo }

  TPackageInfo = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
      function GetversionCode: jint;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      property versionCode: jint read GetversionCode;
  end;

  { TBundle }

  TBundle = class
  private
    FEnv: PJNIEnv;
    FOrigin: jobject;
    FClsDef: jclass;
  public
    constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
    destructor Destroy; override;
    function containsKey(key: jstring): jboolean;
    function getString(key: jstring): jstring;
  end;


  { TApplicationInfo }

  TApplicationInfo = class
  private
    FEnv: PJNIEnv;
    FOrigin: jobject;
    FClsDef: jclass;
    function GetdataDir: jstring;
    function GetmetaData: jobject;
    function GetsourceDir: jstring;

  public
    constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
    destructor Destroy; override;
    property metaData: jobject read GetmetaData;
    property sourceDir: jstring read GetsourceDir;
    property dataDir: jstring read GetdataDir;
    procedure SetclassName(key: jstring);
  end;

  { TPackageManager }

  TPackageManager = class
  private
    FEnv: PJNIEnv;
    FOrigin: jobject;
    FClsDef: jclass;
  public
    constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
    destructor Destroy; override;
    function getApplicationInfo(packageName: jstring; flags: Integer): TApplicationInfo;
    function getPackageInfo(pkgName: jstring; flag: Integer): TPackageInfo;
  end;

  { TContext }

  TContext = class
  private
    FEnv: PJNIEnv;
    FOrigin: jobject;
    FClsDef: jclass;
  public
    constructor Create(AEnv:PJNIEnv; AOrigin: jobject);
    destructor Destroy; override;
    function getPackageManager(): TPackageManager;
    function getPackageName(): jstring;
    function getApplicationInfo(): TApplicationInfo;
  end;

implementation

{ TPackageInfo }

function TPackageInfo.GetversionCode: jint;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'versionCode', 'I');
  Exit(FEnv^^.GetIntField(FEnv, FOrigin, f));
end;

constructor TPackageInfo.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/content/pm/PackageInfo');
end;

destructor TPackageInfo.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TBundle }

constructor TBundle.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/os/Bundle');
end;

destructor TBundle.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TBundle.containsKey(key: jstring): jboolean;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'containsKey', '(Ljava/lang/String;)Z');
  Exit(FEnv^^.CallBooleanMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [key])));
end;

function TBundle.getString(key: jstring): jstring;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getString', '(Ljava/lang/String;)Ljava/lang/String;');
  Exit(jstring(FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [key]))));
end;

{ TPackageManager }

constructor TPackageManager.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/content/pm/PackageManager');
end;

destructor TPackageManager.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TPackageManager.getApplicationInfo(packageName: jstring; flags: Integer
  ): TApplicationInfo;
var
  m: jmethodID;
begin
  m := FEnv^^.GetMethodID(FEnv, FClsDef, 'getApplicationInfo', '(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;');
  Exit(TApplicationInfo.Create(FEnv, FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [packageName, flags]))));
end;

function TPackageManager.getPackageInfo(pkgName: jstring; flag: Integer
  ): TPackageInfo;
var
  m: jmethodID;
begin
  m := FEnv^^.GetMethodID(FEnv, FClsDef, 'getPackageInfo', '(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;');
  Exit(TPackageInfo.Create(FEnv, FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [pkgName, flag]))));
end;

{ TApplicationInfo }

function TApplicationInfo.GetmetaData: jobject;
var
  f: jfieldID;
begin
  f := FEnv^^.GetFieldID(FEnv, FClsDef, 'metaData', 'Landroid/os/Bundle;');
  Exit(FEnv^^.GetObjectField(FEnv, FOrigin, f));
end;

function TApplicationInfo.GetdataDir: jstring;
var
  f: jfieldID;
begin
  f := FEnv^^.GetFieldID(FEnv, FClsDef, 'dataDir', 'Ljava/lang/String;');
  Exit(jstring(FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TApplicationInfo.GetsourceDir: jstring;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'sourceDir', 'Ljava/lang/String;');
  Exit(jstring(FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

constructor TApplicationInfo.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/content/pm/ApplicationInfo');
end;

destructor TApplicationInfo.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TApplicationInfo.SetclassName(key: jstring);
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'className', 'Ljava/lang/String;');
  FEnv^^.SetObjectField(FEnv, FOrigin, f, key);
end;

{ TContext }

constructor TContext.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/content/Context');
end;

destructor TContext.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TContext.getPackageManager: TPackageManager;
var
  m: jmethodID;
begin
  m := FEnv^^.GetMethodID(FEnv, FClsDef, 'getPackageManager', '()Landroid/content/pm/PackageManager;');
  Exit(TPackageManager.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

function TContext.getPackageName: jstring;
var
  m: jmethodID;
begin
  m := FEnv^^.GetMethodID(FEnv, FClsDef, 'getPackageName', '()Ljava/lang/String;');
  Exit(FEnv^^.CallObjectMethod(FEnv, FOrigin, m));
end;

function TContext.getApplicationInfo: TApplicationInfo;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getApplicationInfo', '()Landroid/content/pm/ApplicationInfo;');
  Exit(TApplicationInfo.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

end.

