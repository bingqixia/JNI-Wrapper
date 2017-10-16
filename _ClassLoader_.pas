unit _ClassLoader_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2, android, _context_;
type

  { TBaseBundle }

  TBaseBundle = class
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

  { TClassLoader }

  TClassLoader = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
  end;

  { TClass }

  TClass = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
  end;

  { TLoadedApk }

  TLoadedApk = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
      FmClassLoader: jfieldID;
      function GetmApplicationInfo: TApplicationInfo;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure SetmClassLoader(fieldVaule: jObject);
      procedure SetmApplication(fieldVaule: jobject);
      property mApplicationInfo: TApplicationInfo read GetmApplicationInfo;
      //property mClassLoader: TClassLoader read GetmClassLoader;
      function GetmClassLoader(): jobject;
      function makeApplication(Aflag: jboolean; Aobj: jobject): jobject;


  end;

  { TDexClassLoader }

  TDexClassLoader = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function loadClass(Name: jstring): TClass;
      function NewObj(dexPath: jstring; optimizedDirectory: jstring; libraryPath: jstring; parent: jobject): jobject;
  end;

implementation

{ TBaseBundle }

constructor TBaseBundle.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/os/BaseBundle');
end;

destructor TBaseBundle.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TBaseBundle.containsKey(key: jstring): jboolean;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'containsKey', '(Ljava/lang/String;)Z');
  Exit(FEnv^^.CallBooleanMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [key])));
end;

function TBaseBundle.getString(key: jstring): jstring;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'getString', '(Ljava/lang/String;)Ljava/lang/String;');
  Exit(jstring(FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [key]))));
end;

{ TClass }

constructor TClass.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/lang/Class');
end;

destructor TClass.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TLoadedApk }

function TLoadedApk.GetmClassLoader: jobject;
begin
  //f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mClassLoader', 'Ljava/lang/ClassLoader;');
 // if (Aobj <> nil) then LOGE('GetmClassLoader => wr.get() is not nil');
  Exit(FEnv^^.GetObjectField(FEnv, FOrigin, FmClassLoader));
end;

function TLoadedApk.makeApplication(Aflag: jboolean; Aobj: jobject): jobject;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'makeApplication', '(ZLandroid/app/Instrumentation;)Landroid/app/Application;');
  Exit(FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [Aflag, Aobj])));
end;

procedure TLoadedApk.SetmClassLoader(fieldVaule: jObject);
begin
 // f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mClassLoader', 'Ljava/lang/ClassLoader;');
  FEnv^^.SetObjectField(FEnv, FOrigin, FmClassLoader, fieldVaule);
end;

procedure TLoadedApk.SetmApplication(fieldVaule: jobject);
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mApplication', 'Landroid/app/Application;');
  FEnv^^.SetObjectField(FEnv, FOrigin, f, fieldVaule);
end;

function TLoadedApk.GetmApplicationInfo: TApplicationInfo;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mApplicationInfo', 'Landroid/content/pm/ApplicationInfo;');
  Exit(TApplicationInfo.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;


constructor TLoadedApk.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/LoadedApk');
  FmClassLoader:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mClassLoader', 'Ljava/lang/ClassLoader;');
end;

destructor TLoadedApk.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TClassLoader }

constructor TClassLoader.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/lang/ClassLoader');
end;

destructor TClassLoader.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TDexClassLoader }

constructor TDexClassLoader.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'dalvik/system/DexClassLoader');
end;

destructor TDexClassLoader.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TDexClassLoader.loadClass(Name: jstring): TClass;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'loadClass', '(Ljava/lang/String;)Ljava/lang/Class;');
  Exit(TClass.Create(FEnv, FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [Name]))));
end;

function TDexClassLoader.NewObj(dexPath: jstring; optimizedDirectory: jstring;
  libraryPath: jstring; parent: jobject): jobject;
var
  m: jmethodID;
 // obj: jobject;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, '<init>', '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V');
 // obj:= FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [dexPath, optimizedDirectory, libraryPath, parent]));
  Exit(FEnv^^.NewObjectA(FEnv, FClsDef, m, TJNIEnv.ArgsToJValues(FEnv, [dexPath, optimizedDirectory, libraryPath, parent])));
 // Exit(obj);
end;

end.

