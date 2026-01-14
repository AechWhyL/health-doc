import dataPreferences  from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit'

// 定义 PreferenceUtils 的接口类型
interface PreferenceUtils {
  set: (
    context: Context,
    storeName: string,
    key: string,
    value: dataPreferences.ValueType
  ) => Promise<void>;
  get: (
    context: Context,
    storeName: string,
    key: string
  ) => dataPreferences.ValueType | null;
  deleteFn: (
    context: Context,
    storeName: string,
    key: string
  ) => Promise<void>;
}

// preferenceUtils 函数的实现
export function preferenceUtils(): PreferenceUtils {

  const getStore = (context: Context, storeName: string) => {
    return dataPreferences.getPreferencesSync(context, {
      name: storeName,
    });
  };

  const set = async (
    context: Context,
    storeName: string,
    key: string,
    value: dataPreferences.ValueType
  ) => {
    const store = getStore(context, storeName);
    store.putSync(key, value);
    await store.flush(); // flush操作是将数据进行本地持久化
  };

  const get = (
    context: Context,
    storeName: string,
    key: string
  ): dataPreferences.ValueType | null => {
    const store = getStore(context, storeName);
    return store.getSync(key, null);
  };

  const deleteFn = async (
    context: Context,
    storeName: string,
    key: string
  ) => {
    const store = getStore(context, storeName);
    store.deleteSync(key);
    await store.flush(); // 更新到磁盘
  };

  return {
    set,
    get,
    deleteFn,
  };
}