/// 世界排序方式
enum WorldSortBy {
  name('名称'),
  createdAt('创建时间'),
  updatedAt('更新时间');
  
  final String label;
  const WorldSortBy(this.label);
}

/// 世界筛选选项
enum WorldFilter {
  all('全部'),
  favorites('收藏'),
  recent('最近使用');
  
  final String label;
  const WorldFilter(this.label);
}

/// NPC 关系类型
enum NPCRelationshipType {
  ally('盟友'),
  friend('朋友'),
  neutral('中立'),
  rival('对手'),
  enemy('敌人'),
  family('家人'),
  lover('恋人'),
  mentor('导师'),
  student('学生'),
  colleague('同事');
  
  final String label;
  const NPCRelationshipType(this.label);
}
