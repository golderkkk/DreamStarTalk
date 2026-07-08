/// 角色排序方式
enum CharacterSortBy {
  name('名称'),
  createdAt('创建时间'),
  updatedAt('更新时间');
  
  final String label;
  const CharacterSortBy(this.label);
}

/// 角色筛选选项
enum CharacterFilter {
  all('全部'),
  favorites('收藏'),
  recent('最近使用');
  
  final String label;
  const CharacterFilter(this.label);
}

/// 角色导入格式
enum CharacterImportFormat {
  json('JSON'),
  png('PNG 角色卡'),
  tavernai('TavernAI');
  
  final String label;
  const CharacterImportFormat(this.label);
}

/// 角色导出格式
enum CharacterExportFormat {
  json('JSON'),
  png('PNG 角色卡');
  
  final String label;
  const CharacterExportFormat(this.label);
}
