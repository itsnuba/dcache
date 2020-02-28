part of dcache;

class SimpleExpCache<K, V> extends SimpleCache<K, V> {
  SimpleExpCache({@required Storage<K, V> storage, OnEvict<K, V> onEvict}) : super(storage: storage, onEvict: onEvict);

  @override
  void _loadValue(CacheEntry<K, V> entry) {
    if (!entry.updating) {
      entry.updating = true;
      if (this._loaderFunc != null) {
        this._set(entry.key, this._loaderFunc(entry.key, entry.value));
      } else {
        this._set(entry.key, entry.value);
      }
    }
  }

  @override
  SimpleCache<K, V> _set(K key, V element) {
    if (this._internalStorage.containsKey(key)) {
      CacheEntry<K, V> c = this._internalStorage.get(this._internalStorage.keys.first);
      if (this._expiration != null && new DateTime.now().difference(c.insertTime) >= this._expiration) {
        this._internalStorage.remove(this._internalStorage.keys.first);
        return this;
      } else if (this.length >= this._internalStorage.capacity) {
        this._internalStorage.remove(this._internalStorage.keys.first);
      }
      if (onEvict != null) {
        onEvict(c.key, c.value);
      }
    }
    this._internalStorage[key] = new CacheEntry(key, element, new DateTime.now());
    return this;
  }

}
