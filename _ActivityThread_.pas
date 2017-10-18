unit _ActivityThread_;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, JNI2, _context_, _ClassLoader_, android;

type

  { TContentProvider }

  TContentProvider = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      procedure SetmContext(Aobj: jobject);
  end;

  { TProviderClientRecord }

  TProviderClientRecord = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
      function GetmLocalProvider: TContentProvider;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      property mLocalProvider: TContentProvider read GetmLocalProvider;
  end;

  { TIterator }

  TIterator = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function hasNext(): jboolean;
      function next(): TProviderClientRecord;
  end;

  { TCollection }

  TCollection = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function iterator(): TIterator;
  end;


  { TAppBindData }

  TAppBindData = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
      function GetappInfo: TApplicationInfo;
      function Getinfo: TLoadedApk;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      property info: TLoadedApk read Getinfo;
      property appInfo: TApplicationInfo read GetappInfo;
  end;

  { TWeakReference }

  TWeakReference = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function get(): TLoadedApk;
  end;

  { TArrayList }

  TArrayList = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function remove(Aobj: jobject): jboolean;
  end;

  { TArrayMap }

  TArrayMap = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      function get(key: jobject): TWeakReference;
      function values(): TCollection;
      function size(): Integer;
  end;

  { TActivityThread }

  TActivityThread = class
    private
      FEnv: PJNIEnv;
      FOrigin: jobject;
      FClsDef: jclass;

      function GetmAllApplications: TArrayList;
      function GetmBoundApplication: TAppBindData;
      function GetmInitialApplication: jobject;
      function GetmPackages: TArrayMap;
      function GetmProviderMap: TArrayMap;
    public
      constructor Create(AEnv: PJNIEnv; AOrigin: jobject);
      destructor Destroy; override;
      property mAllApplications: TArrayList read GetmAllApplications;
      property mPackages: TArrayMap read GetmPackages;
      property mBoundApplication: TAppBindData read GetmBoundApplication;
      property mInitialApplication: jobject read GetmInitialApplication;
      property mProviderMap: TArrayMap read GetmProviderMap;
      function currentActivityThread(): TActivityThread;
      procedure SetmInitialApplication(Aobj: jobject);
  end;

implementation

{ TContentProvider }

constructor TContentProvider.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/content/ContentProvider');
end;

destructor TContentProvider.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

procedure TContentProvider.SetmContext(Aobj: jobject);
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mContext', 'Landroid/content/Context;');
  if (FOrigin <> nil) then
    FEnv^^.SetObjectField(FEnv, FOrigin, f, Aobj);
end;

{ TProviderClientRecord }

function TProviderClientRecord.GetmLocalProvider: TContentProvider;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mLocalProvider', 'Landroid/content/ContentProvider;');
  Exit(TContentProvider.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

constructor TProviderClientRecord.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/ActivityThread$ProviderClientRecord');
end;

destructor TProviderClientRecord.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
 // FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TIterator }

constructor TIterator.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/Iterator');
end;

destructor TIterator.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
 // FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TIterator.hasNext: jboolean;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'hasNext', '()Z');
  Exit(FEnv^^.CallBooleanMethod(FEnv, FOrigin, m));
end;

function TIterator.next: TProviderClientRecord;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'next', '()Ljava/lang/Object;');
  Exit(TProviderClientRecord.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

{ TCollection }

constructor TCollection.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/Collection');
end;

destructor TCollection.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
//  FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TCollection.iterator: TIterator;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'iterator', '()Ljava/util/Iterator;');
  Exit(TIterator.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

{ TArrayList }

constructor TArrayList.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/util/ArrayList');
end;

destructor TArrayList.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TArrayList.remove(Aobj: jobject): jboolean;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'remove', '(Ljava/lang/Object;)Z');
  Exit(FEnv^^.CallBooleanMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [Aobj])));
end;

{ TAppBindData }

function TAppBindData.Getinfo: TLoadedApk;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'info', 'Landroid/app/LoadedApk;');
  Exit(TLoadedApk.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TAppBindData.GetappInfo: TApplicationInfo;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'appInfo', 'Landroid/content/pm/ApplicationInfo;');
  Exit(TApplicationInfo.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

constructor TAppBindData.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/ActivityThread$AppBindData');
end;

destructor TAppBindData.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

{ TWeakReference }

constructor TWeakReference.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'java/lang/ref/WeakReference');
end;

destructor TWeakReference.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
 // FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TWeakReference.get: TLoadedApk;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'get', '()Ljava/lang/Object;');
  //LOGE('WeakReference');
  Exit(TLoadedApk.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

{ TArrayMap }
constructor TArrayMap.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/util/ArrayMap');
end;

destructor TArrayMap.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TArrayMap.get(key: jobject): TWeakReference;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'get', '(Ljava/lang/Object;)Ljava/lang/Object;');
  Exit(TWeakReference.Create(FEnv, FEnv^^.CallObjectMethodA(FEnv, FOrigin, m, TJNIEnv.ArgsToJValues(FEnv, [key]))));
end;

function TArrayMap.values: TCollection;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'values', '()Ljava/util/Collection;');
  Exit(TCollection.Create(FEnv, FEnv^^.CallObjectMethod(FEnv, FOrigin, m)));
end;

function TArrayMap.size: Integer;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetMethodID(FEnv, FClsDef, 'size', '()I');
  Exit(FEnv^^.CallIntMethod(FEnv, FOrigin, m));
end;

{ TActivityThread }

function TActivityThread.GetmPackages: TArrayMap;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mPackages', 'Landroid/util/ArrayMap;');
  Exit(TArrayMap.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TActivityThread.GetmProviderMap: TArrayMap;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mProviderMap', 'Landroid/util/ArrayMap;');
  Exit(TArrayMap.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TActivityThread.GetmBoundApplication: TAppBindData;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mBoundApplication', 'Landroid/app/ActivityThread$AppBindData;');
  Exit(TAppBindData.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TActivityThread.GetmAllApplications: TArrayList;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mAllApplications', 'Ljava/util/ArrayList;');
  Exit(TArrayList.Create(FEnv, FEnv^^.GetObjectField(FEnv, FOrigin, f)));
end;

function TActivityThread.GetmInitialApplication: jobject;
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mInitialApplication', 'Landroid/app/Application;');
  Exit(FEnv^^.GetObjectField(FEnv, FOrigin, f));
end;

constructor TActivityThread.Create(AEnv: PJNIEnv; AOrigin: jobject);
begin
  FEnv:= AEnv;
  FOrigin:= AOrigin;
  FClsDef:= FEnv^^.FindClass(FEnv, 'android/app/ActivityThread');
end;

destructor TActivityThread.Destroy;
begin
  FEnv^^.DeleteLocalRef(FEnv, FClsDef);
  //FEnv^^.DeleteLocalRef(FEnv, FOrigin);
  inherited Destroy;
end;

function TActivityThread.currentActivityThread: TActivityThread;
var
  m: jmethodID;
begin
  m:= FEnv^^.GetStaticMethodID(FEnv, FClsDef, 'currentActivityThread', '()Landroid/app/ActivityThread;');
  Exit(TActivityThread.Create(FEnv, FEnv^^.CallStaticObjectMethod(FEnv, FClsDef, m)));
end;

procedure TActivityThread.SetmInitialApplication(Aobj: jobject);
var
  f: jfieldID;
begin
  f:= FEnv^^.GetFieldID(FEnv, FClsDef, 'mInitialApplication', 'Landroid/app/Application;');
  FEnv^^.SetObjectField(FEnv, FOrigin, f, Aobj);
end;

end.

