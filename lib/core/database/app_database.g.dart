// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PedalsTable extends Pedals with TableInfo<$PedalsTable, Pedal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PedalType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PedalType>($PedalsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<PedalCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PedalCategory>($PedalsTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<PedalStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(PedalStatus.active.name),
      ).withConverter<PedalStatus>($PedalsTable.$converterstatus);
  static const VerificationMeta _hostPedalIdMeta = const VerificationMeta(
    'hostPedalId',
  );
  @override
  late final GeneratedColumn<int> hostPedalId = GeneratedColumn<int>(
    'host_pedal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MultiEffectsMode?, String>
  multiEffectsMode = GeneratedColumn<String>(
    'multi_effects_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<MultiEffectsMode?>($PedalsTable.$convertermultiEffectsModen);
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    type,
    category,
    status,
    hostPedalId,
    multiEffectsMode,
    photoPath,
    purchaseDate,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pedal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('host_pedal_id')) {
      context.handle(
        _hostPedalIdMeta,
        hostPedalId.isAcceptableOrUnknown(
          data['host_pedal_id']!,
          _hostPedalIdMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pedal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pedal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      type: $PedalsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      category: $PedalsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      status: $PedalsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      hostPedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}host_pedal_id'],
      ),
      multiEffectsMode: $PedalsTable.$convertermultiEffectsModen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}multi_effects_mode'],
        ),
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PedalsTable createAlias(String alias) {
    return $PedalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PedalType, String, String> $convertertype =
      const EnumNameConverter<PedalType>(PedalType.values);
  static JsonTypeConverter2<PedalCategory, String, String> $convertercategory =
      const EnumNameConverter<PedalCategory>(PedalCategory.values);
  static JsonTypeConverter2<PedalStatus, String, String> $converterstatus =
      const EnumNameConverter<PedalStatus>(PedalStatus.values);
  static JsonTypeConverter2<MultiEffectsMode, String, String>
  $convertermultiEffectsMode = const EnumNameConverter<MultiEffectsMode>(
    MultiEffectsMode.values,
  );
  static JsonTypeConverter2<MultiEffectsMode?, String?, String?>
  $convertermultiEffectsModen = JsonTypeConverter2.asNullable(
    $convertermultiEffectsMode,
  );
}

class Pedal extends DataClass implements Insertable<Pedal> {
  final int id;
  final String name;
  final String? brand;
  final PedalType type;
  final PedalCategory category;
  final PedalStatus status;

  /// The multi-effects unit this pedal is part of, or null when it stands on
  /// its own floor.
  ///
  /// RESTRICT for the same reason every other reference to a pedal is: a unit
  /// with stomps still attached is retired, not deleted, so nothing it holds is
  /// swept away with it.
  final int? hostPedalId;

  /// Dormant. It held how a unit was organised while a unit had to be declared
  /// as stomp mode or scene mode; nothing writes it now and no screen reads it.
  ///
  /// Kept rather than dropped: the rows written before still hold a mode, and
  /// removing a column in SQLite means rebuilding the table, which is not worth
  /// doing to reclaim one nullable field. See [MultiEffectsMode].
  final MultiEffectsMode? multiEffectsMode;

  /// Path to an image file in the app's documents directory. Photos are kept
  /// outside the database so the file stays small and easy to back up.
  final String? photoPath;
  final DateTime? purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Pedal({
    required this.id,
    required this.name,
    this.brand,
    required this.type,
    required this.category,
    required this.status,
    this.hostPedalId,
    this.multiEffectsMode,
    this.photoPath,
    this.purchaseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    {
      map['type'] = Variable<String>($PedalsTable.$convertertype.toSql(type));
    }
    {
      map['category'] = Variable<String>(
        $PedalsTable.$convertercategory.toSql(category),
      );
    }
    {
      map['status'] = Variable<String>(
        $PedalsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || hostPedalId != null) {
      map['host_pedal_id'] = Variable<int>(hostPedalId);
    }
    if (!nullToAbsent || multiEffectsMode != null) {
      map['multi_effects_mode'] = Variable<String>(
        $PedalsTable.$convertermultiEffectsModen.toSql(multiEffectsMode),
      );
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PedalsCompanion toCompanion(bool nullToAbsent) {
    return PedalsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      type: Value(type),
      category: Value(category),
      status: Value(status),
      hostPedalId: hostPedalId == null && nullToAbsent
          ? const Value.absent()
          : Value(hostPedalId),
      multiEffectsMode: multiEffectsMode == null && nullToAbsent
          ? const Value.absent()
          : Value(multiEffectsMode),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Pedal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pedal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      type: $PedalsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      category: $PedalsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      status: $PedalsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      hostPedalId: serializer.fromJson<int?>(json['hostPedalId']),
      multiEffectsMode: $PedalsTable.$convertermultiEffectsModen.fromJson(
        serializer.fromJson<String?>(json['multiEffectsMode']),
      ),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'type': serializer.toJson<String>(
        $PedalsTable.$convertertype.toJson(type),
      ),
      'category': serializer.toJson<String>(
        $PedalsTable.$convertercategory.toJson(category),
      ),
      'status': serializer.toJson<String>(
        $PedalsTable.$converterstatus.toJson(status),
      ),
      'hostPedalId': serializer.toJson<int?>(hostPedalId),
      'multiEffectsMode': serializer.toJson<String?>(
        $PedalsTable.$convertermultiEffectsModen.toJson(multiEffectsMode),
      ),
      'photoPath': serializer.toJson<String?>(photoPath),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Pedal copyWith({
    int? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    PedalType? type,
    PedalCategory? category,
    PedalStatus? status,
    Value<int?> hostPedalId = const Value.absent(),
    Value<MultiEffectsMode?> multiEffectsMode = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<DateTime?> purchaseDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Pedal(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    type: type ?? this.type,
    category: category ?? this.category,
    status: status ?? this.status,
    hostPedalId: hostPedalId.present ? hostPedalId.value : this.hostPedalId,
    multiEffectsMode: multiEffectsMode.present
        ? multiEffectsMode.value
        : this.multiEffectsMode,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Pedal copyWithCompanion(PedalsCompanion data) {
    return Pedal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      hostPedalId: data.hostPedalId.present
          ? data.hostPedalId.value
          : this.hostPedalId,
      multiEffectsMode: data.multiEffectsMode.present
          ? data.multiEffectsMode.value
          : this.multiEffectsMode,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pedal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('hostPedalId: $hostPedalId, ')
          ..write('multiEffectsMode: $multiEffectsMode, ')
          ..write('photoPath: $photoPath, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    type,
    category,
    status,
    hostPedalId,
    multiEffectsMode,
    photoPath,
    purchaseDate,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pedal &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.type == this.type &&
          other.category == this.category &&
          other.status == this.status &&
          other.hostPedalId == this.hostPedalId &&
          other.multiEffectsMode == this.multiEffectsMode &&
          other.photoPath == this.photoPath &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PedalsCompanion extends UpdateCompanion<Pedal> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<PedalType> type;
  final Value<PedalCategory> category;
  final Value<PedalStatus> status;
  final Value<int?> hostPedalId;
  final Value<MultiEffectsMode?> multiEffectsMode;
  final Value<String?> photoPath;
  final Value<DateTime?> purchaseDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PedalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.hostPedalId = const Value.absent(),
    this.multiEffectsMode = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PedalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required PedalType type,
    required PedalCategory category,
    this.status = const Value.absent(),
    this.hostPedalId = const Value.absent(),
    this.multiEffectsMode = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       type = Value(type),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Pedal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? status,
    Expression<int>? hostPedalId,
    Expression<String>? multiEffectsMode,
    Expression<String>? photoPath,
    Expression<DateTime>? purchaseDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (hostPedalId != null) 'host_pedal_id': hostPedalId,
      if (multiEffectsMode != null) 'multi_effects_mode': multiEffectsMode,
      if (photoPath != null) 'photo_path': photoPath,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PedalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<PedalType>? type,
    Value<PedalCategory>? category,
    Value<PedalStatus>? status,
    Value<int?>? hostPedalId,
    Value<MultiEffectsMode?>? multiEffectsMode,
    Value<String?>? photoPath,
    Value<DateTime?>? purchaseDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PedalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      hostPedalId: hostPedalId ?? this.hostPedalId,
      multiEffectsMode: multiEffectsMode ?? this.multiEffectsMode,
      photoPath: photoPath ?? this.photoPath,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PedalsTable.$convertertype.toSql(type.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $PedalsTable.$convertercategory.toSql(category.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PedalsTable.$converterstatus.toSql(status.value),
      );
    }
    if (hostPedalId.present) {
      map['host_pedal_id'] = Variable<int>(hostPedalId.value);
    }
    if (multiEffectsMode.present) {
      map['multi_effects_mode'] = Variable<String>(
        $PedalsTable.$convertermultiEffectsModen.toSql(multiEffectsMode.value),
      );
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('hostPedalId: $hostPedalId, ')
          ..write('multiEffectsMode: $multiEffectsMode, ')
          ..write('photoPath: $photoPath, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PedalControlsTable extends PedalControls
    with TableInfo<$PedalControlsTable, PedalControl> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedalControlsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ControlType, String> controlType =
      GeneratedColumn<String>(
        'control_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ControlType>($PedalControlsTable.$convertercontrolType);
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<double> step = GeneratedColumn<double>(
    'step',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultValueMeta = const VerificationMeta(
    'defaultValue',
  );
  @override
  late final GeneratedColumn<double> defaultValue = GeneratedColumn<double>(
    'default_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 12,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalId,
    name,
    controlType,
    minValue,
    maxValue,
    step,
    defaultValue,
    unit,
    options,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedal_controls';
  @override
  VerificationContext validateIntegrity(
    Insertable<PedalControl> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    } else if (isInserting) {
      context.missing(_minValueMeta);
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    } else if (isInserting) {
      context.missing(_maxValueMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('default_value')) {
      context.handle(
        _defaultValueMeta,
        defaultValue.isAcceptableOrUnknown(
          data['default_value']!,
          _defaultValueMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pedalId, name},
  ];
  @override
  PedalControl map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedalControl(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      controlType: $PedalControlsTable.$convertercontrolType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}control_type'],
        )!,
      ),
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      )!,
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}step'],
      ),
      defaultValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $PedalControlsTable createAlias(String alias) {
    return $PedalControlsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ControlType, String, String> $convertercontrolType =
      const EnumNameConverter<ControlType>(ControlType.values);
}

class PedalControl extends DataClass implements Insertable<PedalControl> {
  final int id;
  final int pedalId;
  final String name;
  final ControlType controlType;

  /// Inclusive bounds every stored value for this control must fall inside.
  /// Clock controls use a normalized `0..1` domain; percentage controls `0..100`.
  final double minValue;
  final double maxValue;

  /// Increment the control snaps to, or null when it is continuous.
  final double? step;
  final double? defaultValue;

  /// Display-only suffix such as `dB`, `ms` or `Hz`.
  final String? unit;

  /// Position names of a selection control, as a JSON array of strings.
  ///
  /// Null for every other control type. A handful of labels is never queried on
  /// its own, so they stay on the control instead of earning a child table, and
  /// the stored value remains a plain number: the position within this list.
  /// Read and written through `decodeControlOptions` / `encodeControlOptions`.
  final String? options;
  final int displayOrder;
  const PedalControl({
    required this.id,
    required this.pedalId,
    required this.name,
    required this.controlType,
    required this.minValue,
    required this.maxValue,
    this.step,
    this.defaultValue,
    this.unit,
    this.options,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedal_id'] = Variable<int>(pedalId);
    map['name'] = Variable<String>(name);
    {
      map['control_type'] = Variable<String>(
        $PedalControlsTable.$convertercontrolType.toSql(controlType),
      );
    }
    map['min_value'] = Variable<double>(minValue);
    map['max_value'] = Variable<double>(maxValue);
    if (!nullToAbsent || step != null) {
      map['step'] = Variable<double>(step);
    }
    if (!nullToAbsent || defaultValue != null) {
      map['default_value'] = Variable<double>(defaultValue);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  PedalControlsCompanion toCompanion(bool nullToAbsent) {
    return PedalControlsCompanion(
      id: Value(id),
      pedalId: Value(pedalId),
      name: Value(name),
      controlType: Value(controlType),
      minValue: Value(minValue),
      maxValue: Value(maxValue),
      step: step == null && nullToAbsent ? const Value.absent() : Value(step),
      defaultValue: defaultValue == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      displayOrder: Value(displayOrder),
    );
  }

  factory PedalControl.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedalControl(
      id: serializer.fromJson<int>(json['id']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
      name: serializer.fromJson<String>(json['name']),
      controlType: $PedalControlsTable.$convertercontrolType.fromJson(
        serializer.fromJson<String>(json['controlType']),
      ),
      minValue: serializer.fromJson<double>(json['minValue']),
      maxValue: serializer.fromJson<double>(json['maxValue']),
      step: serializer.fromJson<double?>(json['step']),
      defaultValue: serializer.fromJson<double?>(json['defaultValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      options: serializer.fromJson<String?>(json['options']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalId': serializer.toJson<int>(pedalId),
      'name': serializer.toJson<String>(name),
      'controlType': serializer.toJson<String>(
        $PedalControlsTable.$convertercontrolType.toJson(controlType),
      ),
      'minValue': serializer.toJson<double>(minValue),
      'maxValue': serializer.toJson<double>(maxValue),
      'step': serializer.toJson<double?>(step),
      'defaultValue': serializer.toJson<double?>(defaultValue),
      'unit': serializer.toJson<String?>(unit),
      'options': serializer.toJson<String?>(options),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  PedalControl copyWith({
    int? id,
    int? pedalId,
    String? name,
    ControlType? controlType,
    double? minValue,
    double? maxValue,
    Value<double?> step = const Value.absent(),
    Value<double?> defaultValue = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> options = const Value.absent(),
    int? displayOrder,
  }) => PedalControl(
    id: id ?? this.id,
    pedalId: pedalId ?? this.pedalId,
    name: name ?? this.name,
    controlType: controlType ?? this.controlType,
    minValue: minValue ?? this.minValue,
    maxValue: maxValue ?? this.maxValue,
    step: step.present ? step.value : this.step,
    defaultValue: defaultValue.present ? defaultValue.value : this.defaultValue,
    unit: unit.present ? unit.value : this.unit,
    options: options.present ? options.value : this.options,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  PedalControl copyWithCompanion(PedalControlsCompanion data) {
    return PedalControl(
      id: data.id.present ? data.id.value : this.id,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      name: data.name.present ? data.name.value : this.name,
      controlType: data.controlType.present
          ? data.controlType.value
          : this.controlType,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      step: data.step.present ? data.step.value : this.step,
      defaultValue: data.defaultValue.present
          ? data.defaultValue.value
          : this.defaultValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      options: data.options.present ? data.options.value : this.options,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedalControl(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('controlType: $controlType, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('step: $step, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('unit: $unit, ')
          ..write('options: $options, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pedalId,
    name,
    controlType,
    minValue,
    maxValue,
    step,
    defaultValue,
    unit,
    options,
    displayOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedalControl &&
          other.id == this.id &&
          other.pedalId == this.pedalId &&
          other.name == this.name &&
          other.controlType == this.controlType &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.step == this.step &&
          other.defaultValue == this.defaultValue &&
          other.unit == this.unit &&
          other.options == this.options &&
          other.displayOrder == this.displayOrder);
}

class PedalControlsCompanion extends UpdateCompanion<PedalControl> {
  final Value<int> id;
  final Value<int> pedalId;
  final Value<String> name;
  final Value<ControlType> controlType;
  final Value<double> minValue;
  final Value<double> maxValue;
  final Value<double?> step;
  final Value<double?> defaultValue;
  final Value<String?> unit;
  final Value<String?> options;
  final Value<int> displayOrder;
  const PedalControlsCompanion({
    this.id = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.name = const Value.absent(),
    this.controlType = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.step = const Value.absent(),
    this.defaultValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.options = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  PedalControlsCompanion.insert({
    this.id = const Value.absent(),
    required int pedalId,
    required String name,
    required ControlType controlType,
    required double minValue,
    required double maxValue,
    this.step = const Value.absent(),
    this.defaultValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.options = const Value.absent(),
    required int displayOrder,
  }) : pedalId = Value(pedalId),
       name = Value(name),
       controlType = Value(controlType),
       minValue = Value(minValue),
       maxValue = Value(maxValue),
       displayOrder = Value(displayOrder);
  static Insertable<PedalControl> custom({
    Expression<int>? id,
    Expression<int>? pedalId,
    Expression<String>? name,
    Expression<String>? controlType,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<double>? step,
    Expression<double>? defaultValue,
    Expression<String>? unit,
    Expression<String>? options,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalId != null) 'pedal_id': pedalId,
      if (name != null) 'name': name,
      if (controlType != null) 'control_type': controlType,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (step != null) 'step': step,
      if (defaultValue != null) 'default_value': defaultValue,
      if (unit != null) 'unit': unit,
      if (options != null) 'options': options,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  PedalControlsCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalId,
    Value<String>? name,
    Value<ControlType>? controlType,
    Value<double>? minValue,
    Value<double>? maxValue,
    Value<double?>? step,
    Value<double?>? defaultValue,
    Value<String?>? unit,
    Value<String?>? options,
    Value<int>? displayOrder,
  }) {
    return PedalControlsCompanion(
      id: id ?? this.id,
      pedalId: pedalId ?? this.pedalId,
      name: name ?? this.name,
      controlType: controlType ?? this.controlType,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      step: step ?? this.step,
      defaultValue: defaultValue ?? this.defaultValue,
      unit: unit ?? this.unit,
      options: options ?? this.options,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (controlType.present) {
      map['control_type'] = Variable<String>(
        $PedalControlsTable.$convertercontrolType.toSql(controlType.value),
      );
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (step.present) {
      map['step'] = Variable<double>(step.value);
    }
    if (defaultValue.present) {
      map['default_value'] = Variable<double>(defaultValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedalControlsCompanion(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('controlType: $controlType, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('step: $step, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('unit: $unit, ')
          ..write('options: $options, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

class $ConfigurationsTable extends Configurations
    with TableInfo<$ConfigurationsTable, Configuration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalId,
    name,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Configuration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pedalId, name},
  ];
  @override
  Configuration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Configuration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConfigurationsTable createAlias(String alias) {
    return $ConfigurationsTable(attachedDatabase, alias);
  }
}

class Configuration extends DataClass implements Insertable<Configuration> {
  final int id;
  final int pedalId;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Configuration({
    required this.id,
    required this.pedalId,
    required this.name,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedal_id'] = Variable<int>(pedalId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return ConfigurationsCompanion(
      id: Value(id),
      pedalId: Value(pedalId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Configuration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Configuration(
      id: serializer.fromJson<int>(json['id']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalId': serializer.toJson<int>(pedalId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Configuration copyWith({
    int? id,
    int? pedalId,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Configuration(
    id: id ?? this.id,
    pedalId: pedalId ?? this.pedalId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Configuration copyWithCompanion(ConfigurationsCompanion data) {
    return Configuration(
      id: data.id.present ? data.id.value : this.id,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Configuration(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pedalId, name, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuration &&
          other.id == this.id &&
          other.pedalId == this.pedalId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConfigurationsCompanion extends UpdateCompanion<Configuration> {
  final Value<int> id;
  final Value<int> pedalId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ConfigurationsCompanion({
    this.id = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConfigurationsCompanion.insert({
    this.id = const Value.absent(),
    required int pedalId,
    required String name,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : pedalId = Value(pedalId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Configuration> custom({
    Expression<int>? id,
    Expression<int>? pedalId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalId != null) 'pedal_id': pedalId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConfigurationsCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalId,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ConfigurationsCompanion(
      id: id ?? this.id,
      pedalId: pedalId ?? this.pedalId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConfigurationValuesTable extends ConfigurationValues
    with TableInfo<$ConfigurationValuesTable, ConfigurationValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigurationValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _configurationIdMeta = const VerificationMeta(
    'configurationId',
  );
  @override
  late final GeneratedColumn<int> configurationId = GeneratedColumn<int>(
    'configuration_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES configurations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _controlIdMeta = const VerificationMeta(
    'controlId',
  );
  @override
  late final GeneratedColumn<int> controlId = GeneratedColumn<int>(
    'control_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedal_controls (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, configurationId, controlId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuration_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigurationValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('configuration_id')) {
      context.handle(
        _configurationIdMeta,
        configurationId.isAcceptableOrUnknown(
          data['configuration_id']!,
          _configurationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configurationIdMeta);
    }
    if (data.containsKey('control_id')) {
      context.handle(
        _controlIdMeta,
        controlId.isAcceptableOrUnknown(data['control_id']!, _controlIdMeta),
      );
    } else if (isInserting) {
      context.missing(_controlIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {configurationId, controlId},
  ];
  @override
  ConfigurationValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigurationValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      configurationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configuration_id'],
      )!,
      controlId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}control_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ConfigurationValuesTable createAlias(String alias) {
    return $ConfigurationValuesTable(attachedDatabase, alias);
  }
}

class ConfigurationValue extends DataClass
    implements Insertable<ConfigurationValue> {
  final int id;
  final int configurationId;
  final int controlId;
  final double value;
  const ConfigurationValue({
    required this.id,
    required this.configurationId,
    required this.controlId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['configuration_id'] = Variable<int>(configurationId);
    map['control_id'] = Variable<int>(controlId);
    map['value'] = Variable<double>(value);
    return map;
  }

  ConfigurationValuesCompanion toCompanion(bool nullToAbsent) {
    return ConfigurationValuesCompanion(
      id: Value(id),
      configurationId: Value(configurationId),
      controlId: Value(controlId),
      value: Value(value),
    );
  }

  factory ConfigurationValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigurationValue(
      id: serializer.fromJson<int>(json['id']),
      configurationId: serializer.fromJson<int>(json['configurationId']),
      controlId: serializer.fromJson<int>(json['controlId']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'configurationId': serializer.toJson<int>(configurationId),
      'controlId': serializer.toJson<int>(controlId),
      'value': serializer.toJson<double>(value),
    };
  }

  ConfigurationValue copyWith({
    int? id,
    int? configurationId,
    int? controlId,
    double? value,
  }) => ConfigurationValue(
    id: id ?? this.id,
    configurationId: configurationId ?? this.configurationId,
    controlId: controlId ?? this.controlId,
    value: value ?? this.value,
  );
  ConfigurationValue copyWithCompanion(ConfigurationValuesCompanion data) {
    return ConfigurationValue(
      id: data.id.present ? data.id.value : this.id,
      configurationId: data.configurationId.present
          ? data.configurationId.value
          : this.configurationId,
      controlId: data.controlId.present ? data.controlId.value : this.controlId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigurationValue(')
          ..write('id: $id, ')
          ..write('configurationId: $configurationId, ')
          ..write('controlId: $controlId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, configurationId, controlId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigurationValue &&
          other.id == this.id &&
          other.configurationId == this.configurationId &&
          other.controlId == this.controlId &&
          other.value == this.value);
}

class ConfigurationValuesCompanion extends UpdateCompanion<ConfigurationValue> {
  final Value<int> id;
  final Value<int> configurationId;
  final Value<int> controlId;
  final Value<double> value;
  const ConfigurationValuesCompanion({
    this.id = const Value.absent(),
    this.configurationId = const Value.absent(),
    this.controlId = const Value.absent(),
    this.value = const Value.absent(),
  });
  ConfigurationValuesCompanion.insert({
    this.id = const Value.absent(),
    required int configurationId,
    required int controlId,
    required double value,
  }) : configurationId = Value(configurationId),
       controlId = Value(controlId),
       value = Value(value);
  static Insertable<ConfigurationValue> custom({
    Expression<int>? id,
    Expression<int>? configurationId,
    Expression<int>? controlId,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (configurationId != null) 'configuration_id': configurationId,
      if (controlId != null) 'control_id': controlId,
      if (value != null) 'value': value,
    });
  }

  ConfigurationValuesCompanion copyWith({
    Value<int>? id,
    Value<int>? configurationId,
    Value<int>? controlId,
    Value<double>? value,
  }) {
    return ConfigurationValuesCompanion(
      id: id ?? this.id,
      configurationId: configurationId ?? this.configurationId,
      controlId: controlId ?? this.controlId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (configurationId.present) {
      map['configuration_id'] = Variable<int>(configurationId.value);
    }
    if (controlId.present) {
      map['control_id'] = Variable<int>(controlId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigurationValuesCompanion(')
          ..write('id: $id, ')
          ..write('configurationId: $configurationId, ')
          ..write('controlId: $controlId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $PatchesTable extends Patches with TableInfo<$PatchesTable, Patch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalId,
    name,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pedalId, name},
  ];
  @override
  Patch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PatchesTable createAlias(String alias) {
    return $PatchesTable(attachedDatabase, alias);
  }
}

class Patch extends DataClass implements Insertable<Patch> {
  final int id;

  /// The unit this patch is on. Restricted rather than cascading, for the same
  /// reason a pedal with configurations cannot be deleted: retiring gear is what
  /// keeps its history.
  final int pedalId;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Patch({
    required this.id,
    required this.pedalId,
    required this.name,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedal_id'] = Variable<int>(pedalId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatchesCompanion toCompanion(bool nullToAbsent) {
    return PatchesCompanion(
      id: Value(id),
      pedalId: Value(pedalId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Patch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patch(
      id: serializer.fromJson<int>(json['id']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalId': serializer.toJson<int>(pedalId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Patch copyWith({
    int? id,
    int? pedalId,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Patch(
    id: id ?? this.id,
    pedalId: pedalId ?? this.pedalId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Patch copyWithCompanion(PatchesCompanion data) {
    return Patch(
      id: data.id.present ? data.id.value : this.id,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patch(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pedalId, name, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patch &&
          other.id == this.id &&
          other.pedalId == this.pedalId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatchesCompanion extends UpdateCompanion<Patch> {
  final Value<int> id;
  final Value<int> pedalId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PatchesCompanion({
    this.id = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PatchesCompanion.insert({
    this.id = const Value.absent(),
    required int pedalId,
    required String name,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : pedalId = Value(pedalId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Patch> custom({
    Expression<int>? id,
    Expression<int>? pedalId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalId != null) 'pedal_id': pedalId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PatchesCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalId,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PatchesCompanion(
      id: id ?? this.id,
      pedalId: pedalId ?? this.pedalId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatchesCompanion(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScenesTable extends Scenes with TableInfo<$ScenesTable, Scene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patchIdMeta = const VerificationMeta(
    'patchId',
  );
  @override
  late final GeneratedColumn<int> patchId = GeneratedColumn<int>(
    'patch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patchId,
    name,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scene> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patch_id')) {
      context.handle(
        _patchIdMeta,
        patchId.isAcceptableOrUnknown(data['patch_id']!, _patchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patchIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {patchId, name},
  ];
  @override
  Scene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scene(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patch_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScenesTable createAlias(String alias) {
    return $ScenesTable(attachedDatabase, alias);
  }
}

class Scene extends DataClass implements Insertable<Scene> {
  final int id;
  final int patchId;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Scene({
    required this.id,
    required this.patchId,
    required this.name,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patch_id'] = Variable<int>(patchId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScenesCompanion toCompanion(bool nullToAbsent) {
    return ScenesCompanion(
      id: Value(id),
      patchId: Value(patchId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Scene.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scene(
      id: serializer.fromJson<int>(json['id']),
      patchId: serializer.fromJson<int>(json['patchId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patchId': serializer.toJson<int>(patchId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Scene copyWith({
    int? id,
    int? patchId,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Scene(
    id: id ?? this.id,
    patchId: patchId ?? this.patchId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Scene copyWithCompanion(ScenesCompanion data) {
    return Scene(
      id: data.id.present ? data.id.value : this.id,
      patchId: data.patchId.present ? data.patchId.value : this.patchId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scene(')
          ..write('id: $id, ')
          ..write('patchId: $patchId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patchId, name, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scene &&
          other.id == this.id &&
          other.patchId == this.patchId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScenesCompanion extends UpdateCompanion<Scene> {
  final Value<int> id;
  final Value<int> patchId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ScenesCompanion({
    this.id = const Value.absent(),
    this.patchId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScenesCompanion.insert({
    this.id = const Value.absent(),
    required int patchId,
    required String name,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : patchId = Value(patchId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Scene> custom({
    Expression<int>? id,
    Expression<int>? patchId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patchId != null) 'patch_id': patchId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScenesCompanion copyWith({
    Value<int>? id,
    Value<int>? patchId,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ScenesCompanion(
      id: id ?? this.id,
      patchId: patchId ?? this.patchId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patchId.present) {
      map['patch_id'] = Variable<int>(patchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenesCompanion(')
          ..write('id: $id, ')
          ..write('patchId: $patchId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScenePedalsTable extends ScenePedals
    with TableInfo<$ScenePedalsTable, ScenePedal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenePedalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  @override
  late final GeneratedColumn<int> sceneId = GeneratedColumn<int>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scenes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, sceneId, pedalId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scene_pedals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScenePedal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sceneId, pedalId},
  ];
  @override
  ScenePedal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScenePedal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scene_id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
    );
  }

  @override
  $ScenePedalsTable createAlias(String alias) {
    return $ScenePedalsTable(attachedDatabase, alias);
  }
}

class ScenePedal extends DataClass implements Insertable<ScenePedal> {
  final int id;
  final int sceneId;

  /// Restricted, as everywhere a pedal is pointed at: a pedal a scene uses is
  /// retired rather than deleted.
  final int pedalId;
  const ScenePedal({
    required this.id,
    required this.sceneId,
    required this.pedalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scene_id'] = Variable<int>(sceneId);
    map['pedal_id'] = Variable<int>(pedalId);
    return map;
  }

  ScenePedalsCompanion toCompanion(bool nullToAbsent) {
    return ScenePedalsCompanion(
      id: Value(id),
      sceneId: Value(sceneId),
      pedalId: Value(pedalId),
    );
  }

  factory ScenePedal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScenePedal(
      id: serializer.fromJson<int>(json['id']),
      sceneId: serializer.fromJson<int>(json['sceneId']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sceneId': serializer.toJson<int>(sceneId),
      'pedalId': serializer.toJson<int>(pedalId),
    };
  }

  ScenePedal copyWith({int? id, int? sceneId, int? pedalId}) => ScenePedal(
    id: id ?? this.id,
    sceneId: sceneId ?? this.sceneId,
    pedalId: pedalId ?? this.pedalId,
  );
  ScenePedal copyWithCompanion(ScenePedalsCompanion data) {
    return ScenePedal(
      id: data.id.present ? data.id.value : this.id,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScenePedal(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('pedalId: $pedalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sceneId, pedalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScenePedal &&
          other.id == this.id &&
          other.sceneId == this.sceneId &&
          other.pedalId == this.pedalId);
}

class ScenePedalsCompanion extends UpdateCompanion<ScenePedal> {
  final Value<int> id;
  final Value<int> sceneId;
  final Value<int> pedalId;
  const ScenePedalsCompanion({
    this.id = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.pedalId = const Value.absent(),
  });
  ScenePedalsCompanion.insert({
    this.id = const Value.absent(),
    required int sceneId,
    required int pedalId,
  }) : sceneId = Value(sceneId),
       pedalId = Value(pedalId);
  static Insertable<ScenePedal> custom({
    Expression<int>? id,
    Expression<int>? sceneId,
    Expression<int>? pedalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sceneId != null) 'scene_id': sceneId,
      if (pedalId != null) 'pedal_id': pedalId,
    });
  }

  ScenePedalsCompanion copyWith({
    Value<int>? id,
    Value<int>? sceneId,
    Value<int>? pedalId,
  }) {
    return ScenePedalsCompanion(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      pedalId: pedalId ?? this.pedalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<int>(sceneId.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenePedalsCompanion(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('pedalId: $pedalId')
          ..write(')'))
        .toString();
  }
}

class $SceneValuesTable extends SceneValues
    with TableInfo<$SceneValuesTable, SceneValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SceneValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  @override
  late final GeneratedColumn<int> sceneId = GeneratedColumn<int>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scenes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _controlIdMeta = const VerificationMeta(
    'controlId',
  );
  @override
  late final GeneratedColumn<int> controlId = GeneratedColumn<int>(
    'control_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedal_controls (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sceneId, controlId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scene_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<SceneValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('control_id')) {
      context.handle(
        _controlIdMeta,
        controlId.isAcceptableOrUnknown(data['control_id']!, _controlIdMeta),
      );
    } else if (isInserting) {
      context.missing(_controlIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sceneId, controlId},
  ];
  @override
  SceneValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SceneValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scene_id'],
      )!,
      controlId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}control_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SceneValuesTable createAlias(String alias) {
    return $SceneValuesTable(attachedDatabase, alias);
  }
}

class SceneValue extends DataClass implements Insertable<SceneValue> {
  final int id;
  final int sceneId;
  final int controlId;
  final double value;
  const SceneValue({
    required this.id,
    required this.sceneId,
    required this.controlId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scene_id'] = Variable<int>(sceneId);
    map['control_id'] = Variable<int>(controlId);
    map['value'] = Variable<double>(value);
    return map;
  }

  SceneValuesCompanion toCompanion(bool nullToAbsent) {
    return SceneValuesCompanion(
      id: Value(id),
      sceneId: Value(sceneId),
      controlId: Value(controlId),
      value: Value(value),
    );
  }

  factory SceneValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SceneValue(
      id: serializer.fromJson<int>(json['id']),
      sceneId: serializer.fromJson<int>(json['sceneId']),
      controlId: serializer.fromJson<int>(json['controlId']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sceneId': serializer.toJson<int>(sceneId),
      'controlId': serializer.toJson<int>(controlId),
      'value': serializer.toJson<double>(value),
    };
  }

  SceneValue copyWith({int? id, int? sceneId, int? controlId, double? value}) =>
      SceneValue(
        id: id ?? this.id,
        sceneId: sceneId ?? this.sceneId,
        controlId: controlId ?? this.controlId,
        value: value ?? this.value,
      );
  SceneValue copyWithCompanion(SceneValuesCompanion data) {
    return SceneValue(
      id: data.id.present ? data.id.value : this.id,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      controlId: data.controlId.present ? data.controlId.value : this.controlId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SceneValue(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('controlId: $controlId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sceneId, controlId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SceneValue &&
          other.id == this.id &&
          other.sceneId == this.sceneId &&
          other.controlId == this.controlId &&
          other.value == this.value);
}

class SceneValuesCompanion extends UpdateCompanion<SceneValue> {
  final Value<int> id;
  final Value<int> sceneId;
  final Value<int> controlId;
  final Value<double> value;
  const SceneValuesCompanion({
    this.id = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.controlId = const Value.absent(),
    this.value = const Value.absent(),
  });
  SceneValuesCompanion.insert({
    this.id = const Value.absent(),
    required int sceneId,
    required int controlId,
    required double value,
  }) : sceneId = Value(sceneId),
       controlId = Value(controlId),
       value = Value(value);
  static Insertable<SceneValue> custom({
    Expression<int>? id,
    Expression<int>? sceneId,
    Expression<int>? controlId,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sceneId != null) 'scene_id': sceneId,
      if (controlId != null) 'control_id': controlId,
      if (value != null) 'value': value,
    });
  }

  SceneValuesCompanion copyWith({
    Value<int>? id,
    Value<int>? sceneId,
    Value<int>? controlId,
    Value<double>? value,
  }) {
    return SceneValuesCompanion(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      controlId: controlId ?? this.controlId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<int>(sceneId.value);
    }
    if (controlId.present) {
      map['control_id'] = Variable<int>(controlId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SceneValuesCompanion(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('controlId: $controlId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogsTable extends ChangeLogs
    with TableInfo<$ChangeLogsTable, ChangeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _configurationIdMeta = const VerificationMeta(
    'configurationId',
  );
  @override
  late final GeneratedColumn<int> configurationId = GeneratedColumn<int>(
    'configuration_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES configurations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _controlIdMeta = const VerificationMeta(
    'controlId',
  );
  @override
  late final GeneratedColumn<int> controlId = GeneratedColumn<int>(
    'control_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedal_controls (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _configurationNameMeta = const VerificationMeta(
    'configurationName',
  );
  @override
  late final GeneratedColumn<String> configurationName =
      GeneratedColumn<String>(
        'configuration_name',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 80,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _controlNameMeta = const VerificationMeta(
    'controlName',
  );
  @override
  late final GeneratedColumn<String> controlName = GeneratedColumn<String>(
    'control_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _controlPedalNameMeta = const VerificationMeta(
    'controlPedalName',
  );
  @override
  late final GeneratedColumn<String> controlPedalName = GeneratedColumn<String>(
    'control_pedal_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChangeType, String> changeType =
      GeneratedColumn<String>(
        'change_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChangeType>($ChangeLogsTable.$converterchangeType);
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<double> oldValue = GeneratedColumn<double>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<double> newValue = GeneratedColumn<double>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldTextMeta = const VerificationMeta(
    'oldText',
  );
  @override
  late final GeneratedColumn<String> oldText = GeneratedColumn<String>(
    'old_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newTextMeta = const VerificationMeta(
    'newText',
  );
  @override
  late final GeneratedColumn<String> newText = GeneratedColumn<String>(
    'new_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalId,
    configurationId,
    controlId,
    configurationName,
    controlName,
    controlPedalName,
    changeType,
    oldValue,
    newValue,
    oldText,
    newText,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    if (data.containsKey('configuration_id')) {
      context.handle(
        _configurationIdMeta,
        configurationId.isAcceptableOrUnknown(
          data['configuration_id']!,
          _configurationIdMeta,
        ),
      );
    }
    if (data.containsKey('control_id')) {
      context.handle(
        _controlIdMeta,
        controlId.isAcceptableOrUnknown(data['control_id']!, _controlIdMeta),
      );
    }
    if (data.containsKey('configuration_name')) {
      context.handle(
        _configurationNameMeta,
        configurationName.isAcceptableOrUnknown(
          data['configuration_name']!,
          _configurationNameMeta,
        ),
      );
    }
    if (data.containsKey('control_name')) {
      context.handle(
        _controlNameMeta,
        controlName.isAcceptableOrUnknown(
          data['control_name']!,
          _controlNameMeta,
        ),
      );
    }
    if (data.containsKey('control_pedal_name')) {
      context.handle(
        _controlPedalNameMeta,
        controlPedalName.isAcceptableOrUnknown(
          data['control_pedal_name']!,
          _controlPedalNameMeta,
        ),
      );
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('old_text')) {
      context.handle(
        _oldTextMeta,
        oldText.isAcceptableOrUnknown(data['old_text']!, _oldTextMeta),
      );
    }
    if (data.containsKey('new_text')) {
      context.handle(
        _newTextMeta,
        newText.isAcceptableOrUnknown(data['new_text']!, _newTextMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
      configurationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configuration_id'],
      ),
      controlId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}control_id'],
      ),
      configurationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_name'],
      ),
      controlName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_name'],
      ),
      controlPedalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_pedal_name'],
      ),
      changeType: $ChangeLogsTable.$converterchangeType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}change_type'],
        )!,
      ),
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_value'],
      ),
      oldText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_text'],
      ),
      newText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_text'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChangeLogsTable createAlias(String alias) {
    return $ChangeLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ChangeType, String, String> $converterchangeType =
      const EnumNameConverter<ChangeType>(ChangeType.values);
}

class ChangeLog extends DataClass implements Insertable<ChangeLog> {
  final int id;
  final int pedalId;
  final int? configurationId;
  final int? controlId;
  final String? configurationName;
  final String? controlName;

  /// The pedal [controlName] is on, when that is not the pedal this entry is
  /// filed under.
  ///
  /// Null on everything else, which is every entry about a pedal's own controls.
  /// It is set for a scene of a multi-effects unit: the entry is filed under the
  /// unit, but the control it moved lives on one of the pedals inside it, and
  /// "Level moved to 2:30" says nothing when three of them have a Level.
  final String? controlPedalName;
  final ChangeType changeType;

  /// Set only for events that move a control, in that control's own domain.
  final double? oldValue;
  final double? newValue;

  /// The same transition for events that change text rather than a number: a
  /// configuration's name, a pedal's status, or which pedal took over from
  /// which. Kept separate from [reason] so the user can still explain a rename.
  final String? oldText;
  final String? newText;

  /// The user's own explanation, e.g. "needed more saturation for lead".
  final String? reason;
  final DateTime createdAt;
  const ChangeLog({
    required this.id,
    required this.pedalId,
    this.configurationId,
    this.controlId,
    this.configurationName,
    this.controlName,
    this.controlPedalName,
    required this.changeType,
    this.oldValue,
    this.newValue,
    this.oldText,
    this.newText,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedal_id'] = Variable<int>(pedalId);
    if (!nullToAbsent || configurationId != null) {
      map['configuration_id'] = Variable<int>(configurationId);
    }
    if (!nullToAbsent || controlId != null) {
      map['control_id'] = Variable<int>(controlId);
    }
    if (!nullToAbsent || configurationName != null) {
      map['configuration_name'] = Variable<String>(configurationName);
    }
    if (!nullToAbsent || controlName != null) {
      map['control_name'] = Variable<String>(controlName);
    }
    if (!nullToAbsent || controlPedalName != null) {
      map['control_pedal_name'] = Variable<String>(controlPedalName);
    }
    {
      map['change_type'] = Variable<String>(
        $ChangeLogsTable.$converterchangeType.toSql(changeType),
      );
    }
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<double>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<double>(newValue);
    }
    if (!nullToAbsent || oldText != null) {
      map['old_text'] = Variable<String>(oldText);
    }
    if (!nullToAbsent || newText != null) {
      map['new_text'] = Variable<String>(newText);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChangeLogsCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogsCompanion(
      id: Value(id),
      pedalId: Value(pedalId),
      configurationId: configurationId == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationId),
      controlId: controlId == null && nullToAbsent
          ? const Value.absent()
          : Value(controlId),
      configurationName: configurationName == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationName),
      controlName: controlName == null && nullToAbsent
          ? const Value.absent()
          : Value(controlName),
      controlPedalName: controlPedalName == null && nullToAbsent
          ? const Value.absent()
          : Value(controlPedalName),
      changeType: Value(changeType),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      oldText: oldText == null && nullToAbsent
          ? const Value.absent()
          : Value(oldText),
      newText: newText == null && nullToAbsent
          ? const Value.absent()
          : Value(newText),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory ChangeLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLog(
      id: serializer.fromJson<int>(json['id']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
      configurationId: serializer.fromJson<int?>(json['configurationId']),
      controlId: serializer.fromJson<int?>(json['controlId']),
      configurationName: serializer.fromJson<String?>(
        json['configurationName'],
      ),
      controlName: serializer.fromJson<String?>(json['controlName']),
      controlPedalName: serializer.fromJson<String?>(json['controlPedalName']),
      changeType: $ChangeLogsTable.$converterchangeType.fromJson(
        serializer.fromJson<String>(json['changeType']),
      ),
      oldValue: serializer.fromJson<double?>(json['oldValue']),
      newValue: serializer.fromJson<double?>(json['newValue']),
      oldText: serializer.fromJson<String?>(json['oldText']),
      newText: serializer.fromJson<String?>(json['newText']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalId': serializer.toJson<int>(pedalId),
      'configurationId': serializer.toJson<int?>(configurationId),
      'controlId': serializer.toJson<int?>(controlId),
      'configurationName': serializer.toJson<String?>(configurationName),
      'controlName': serializer.toJson<String?>(controlName),
      'controlPedalName': serializer.toJson<String?>(controlPedalName),
      'changeType': serializer.toJson<String>(
        $ChangeLogsTable.$converterchangeType.toJson(changeType),
      ),
      'oldValue': serializer.toJson<double?>(oldValue),
      'newValue': serializer.toJson<double?>(newValue),
      'oldText': serializer.toJson<String?>(oldText),
      'newText': serializer.toJson<String?>(newText),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChangeLog copyWith({
    int? id,
    int? pedalId,
    Value<int?> configurationId = const Value.absent(),
    Value<int?> controlId = const Value.absent(),
    Value<String?> configurationName = const Value.absent(),
    Value<String?> controlName = const Value.absent(),
    Value<String?> controlPedalName = const Value.absent(),
    ChangeType? changeType,
    Value<double?> oldValue = const Value.absent(),
    Value<double?> newValue = const Value.absent(),
    Value<String?> oldText = const Value.absent(),
    Value<String?> newText = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => ChangeLog(
    id: id ?? this.id,
    pedalId: pedalId ?? this.pedalId,
    configurationId: configurationId.present
        ? configurationId.value
        : this.configurationId,
    controlId: controlId.present ? controlId.value : this.controlId,
    configurationName: configurationName.present
        ? configurationName.value
        : this.configurationName,
    controlName: controlName.present ? controlName.value : this.controlName,
    controlPedalName: controlPedalName.present
        ? controlPedalName.value
        : this.controlPedalName,
    changeType: changeType ?? this.changeType,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    oldText: oldText.present ? oldText.value : this.oldText,
    newText: newText.present ? newText.value : this.newText,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  ChangeLog copyWithCompanion(ChangeLogsCompanion data) {
    return ChangeLog(
      id: data.id.present ? data.id.value : this.id,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      configurationId: data.configurationId.present
          ? data.configurationId.value
          : this.configurationId,
      controlId: data.controlId.present ? data.controlId.value : this.controlId,
      configurationName: data.configurationName.present
          ? data.configurationName.value
          : this.configurationName,
      controlName: data.controlName.present
          ? data.controlName.value
          : this.controlName,
      controlPedalName: data.controlPedalName.present
          ? data.controlPedalName.value
          : this.controlPedalName,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      oldText: data.oldText.present ? data.oldText.value : this.oldText,
      newText: data.newText.present ? data.newText.value : this.newText,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLog(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('configurationId: $configurationId, ')
          ..write('controlId: $controlId, ')
          ..write('configurationName: $configurationName, ')
          ..write('controlName: $controlName, ')
          ..write('controlPedalName: $controlPedalName, ')
          ..write('changeType: $changeType, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('oldText: $oldText, ')
          ..write('newText: $newText, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pedalId,
    configurationId,
    controlId,
    configurationName,
    controlName,
    controlPedalName,
    changeType,
    oldValue,
    newValue,
    oldText,
    newText,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLog &&
          other.id == this.id &&
          other.pedalId == this.pedalId &&
          other.configurationId == this.configurationId &&
          other.controlId == this.controlId &&
          other.configurationName == this.configurationName &&
          other.controlName == this.controlName &&
          other.controlPedalName == this.controlPedalName &&
          other.changeType == this.changeType &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.oldText == this.oldText &&
          other.newText == this.newText &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class ChangeLogsCompanion extends UpdateCompanion<ChangeLog> {
  final Value<int> id;
  final Value<int> pedalId;
  final Value<int?> configurationId;
  final Value<int?> controlId;
  final Value<String?> configurationName;
  final Value<String?> controlName;
  final Value<String?> controlPedalName;
  final Value<ChangeType> changeType;
  final Value<double?> oldValue;
  final Value<double?> newValue;
  final Value<String?> oldText;
  final Value<String?> newText;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  const ChangeLogsCompanion({
    this.id = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.configurationId = const Value.absent(),
    this.controlId = const Value.absent(),
    this.configurationName = const Value.absent(),
    this.controlName = const Value.absent(),
    this.controlPedalName = const Value.absent(),
    this.changeType = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.oldText = const Value.absent(),
    this.newText = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChangeLogsCompanion.insert({
    this.id = const Value.absent(),
    required int pedalId,
    this.configurationId = const Value.absent(),
    this.controlId = const Value.absent(),
    this.configurationName = const Value.absent(),
    this.controlName = const Value.absent(),
    this.controlPedalName = const Value.absent(),
    required ChangeType changeType,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.oldText = const Value.absent(),
    this.newText = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
  }) : pedalId = Value(pedalId),
       changeType = Value(changeType),
       createdAt = Value(createdAt);
  static Insertable<ChangeLog> custom({
    Expression<int>? id,
    Expression<int>? pedalId,
    Expression<int>? configurationId,
    Expression<int>? controlId,
    Expression<String>? configurationName,
    Expression<String>? controlName,
    Expression<String>? controlPedalName,
    Expression<String>? changeType,
    Expression<double>? oldValue,
    Expression<double>? newValue,
    Expression<String>? oldText,
    Expression<String>? newText,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalId != null) 'pedal_id': pedalId,
      if (configurationId != null) 'configuration_id': configurationId,
      if (controlId != null) 'control_id': controlId,
      if (configurationName != null) 'configuration_name': configurationName,
      if (controlName != null) 'control_name': controlName,
      if (controlPedalName != null) 'control_pedal_name': controlPedalName,
      if (changeType != null) 'change_type': changeType,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (oldText != null) 'old_text': oldText,
      if (newText != null) 'new_text': newText,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChangeLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalId,
    Value<int?>? configurationId,
    Value<int?>? controlId,
    Value<String?>? configurationName,
    Value<String?>? controlName,
    Value<String?>? controlPedalName,
    Value<ChangeType>? changeType,
    Value<double?>? oldValue,
    Value<double?>? newValue,
    Value<String?>? oldText,
    Value<String?>? newText,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
  }) {
    return ChangeLogsCompanion(
      id: id ?? this.id,
      pedalId: pedalId ?? this.pedalId,
      configurationId: configurationId ?? this.configurationId,
      controlId: controlId ?? this.controlId,
      configurationName: configurationName ?? this.configurationName,
      controlName: controlName ?? this.controlName,
      controlPedalName: controlPedalName ?? this.controlPedalName,
      changeType: changeType ?? this.changeType,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      oldText: oldText ?? this.oldText,
      newText: newText ?? this.newText,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (configurationId.present) {
      map['configuration_id'] = Variable<int>(configurationId.value);
    }
    if (controlId.present) {
      map['control_id'] = Variable<int>(controlId.value);
    }
    if (configurationName.present) {
      map['configuration_name'] = Variable<String>(configurationName.value);
    }
    if (controlName.present) {
      map['control_name'] = Variable<String>(controlName.value);
    }
    if (controlPedalName.present) {
      map['control_pedal_name'] = Variable<String>(controlPedalName.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(
        $ChangeLogsTable.$converterchangeType.toSql(changeType.value),
      );
    }
    if (oldValue.present) {
      map['old_value'] = Variable<double>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<double>(newValue.value);
    }
    if (oldText.present) {
      map['old_text'] = Variable<String>(oldText.value);
    }
    if (newText.present) {
      map['new_text'] = Variable<String>(newText.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogsCompanion(')
          ..write('id: $id, ')
          ..write('pedalId: $pedalId, ')
          ..write('configurationId: $configurationId, ')
          ..write('controlId: $controlId, ')
          ..write('configurationName: $configurationName, ')
          ..write('controlName: $controlName, ')
          ..write('controlPedalName: $controlPedalName, ')
          ..write('changeType: $changeType, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('oldText: $oldText, ')
          ..write('newText: $newText, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PedalReplacementsTable extends PedalReplacements
    with TableInfo<$PedalReplacementsTable, PedalReplacement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedalReplacementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _oldPedalIdMeta = const VerificationMeta(
    'oldPedalId',
  );
  @override
  late final GeneratedColumn<int> oldPedalId = GeneratedColumn<int>(
    'old_pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _newPedalIdMeta = const VerificationMeta(
    'newPedalId',
  );
  @override
  late final GeneratedColumn<int> newPedalId = GeneratedColumn<int>(
    'new_pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacedAtMeta = const VerificationMeta(
    'replacedAt',
  );
  @override
  late final GeneratedColumn<DateTime> replacedAt = GeneratedColumn<DateTime>(
    'replaced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    oldPedalId,
    newPedalId,
    reason,
    replacedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedal_replacements';
  @override
  VerificationContext validateIntegrity(
    Insertable<PedalReplacement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('old_pedal_id')) {
      context.handle(
        _oldPedalIdMeta,
        oldPedalId.isAcceptableOrUnknown(
          data['old_pedal_id']!,
          _oldPedalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oldPedalIdMeta);
    }
    if (data.containsKey('new_pedal_id')) {
      context.handle(
        _newPedalIdMeta,
        newPedalId.isAcceptableOrUnknown(
          data['new_pedal_id']!,
          _newPedalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newPedalIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('replaced_at')) {
      context.handle(
        _replacedAtMeta,
        replacedAt.isAcceptableOrUnknown(data['replaced_at']!, _replacedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_replacedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PedalReplacement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedalReplacement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      oldPedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_pedal_id'],
      )!,
      newPedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_pedal_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      replacedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}replaced_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PedalReplacementsTable createAlias(String alias) {
    return $PedalReplacementsTable(attachedDatabase, alias);
  }
}

class PedalReplacement extends DataClass
    implements Insertable<PedalReplacement> {
  final int id;
  final int oldPedalId;
  final int newPedalId;
  final String? reason;
  final DateTime replacedAt;
  final String? notes;
  const PedalReplacement({
    required this.id,
    required this.oldPedalId,
    required this.newPedalId,
    this.reason,
    required this.replacedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['old_pedal_id'] = Variable<int>(oldPedalId);
    map['new_pedal_id'] = Variable<int>(newPedalId);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['replaced_at'] = Variable<DateTime>(replacedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PedalReplacementsCompanion toCompanion(bool nullToAbsent) {
    return PedalReplacementsCompanion(
      id: Value(id),
      oldPedalId: Value(oldPedalId),
      newPedalId: Value(newPedalId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      replacedAt: Value(replacedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PedalReplacement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedalReplacement(
      id: serializer.fromJson<int>(json['id']),
      oldPedalId: serializer.fromJson<int>(json['oldPedalId']),
      newPedalId: serializer.fromJson<int>(json['newPedalId']),
      reason: serializer.fromJson<String?>(json['reason']),
      replacedAt: serializer.fromJson<DateTime>(json['replacedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'oldPedalId': serializer.toJson<int>(oldPedalId),
      'newPedalId': serializer.toJson<int>(newPedalId),
      'reason': serializer.toJson<String?>(reason),
      'replacedAt': serializer.toJson<DateTime>(replacedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PedalReplacement copyWith({
    int? id,
    int? oldPedalId,
    int? newPedalId,
    Value<String?> reason = const Value.absent(),
    DateTime? replacedAt,
    Value<String?> notes = const Value.absent(),
  }) => PedalReplacement(
    id: id ?? this.id,
    oldPedalId: oldPedalId ?? this.oldPedalId,
    newPedalId: newPedalId ?? this.newPedalId,
    reason: reason.present ? reason.value : this.reason,
    replacedAt: replacedAt ?? this.replacedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  PedalReplacement copyWithCompanion(PedalReplacementsCompanion data) {
    return PedalReplacement(
      id: data.id.present ? data.id.value : this.id,
      oldPedalId: data.oldPedalId.present
          ? data.oldPedalId.value
          : this.oldPedalId,
      newPedalId: data.newPedalId.present
          ? data.newPedalId.value
          : this.newPedalId,
      reason: data.reason.present ? data.reason.value : this.reason,
      replacedAt: data.replacedAt.present
          ? data.replacedAt.value
          : this.replacedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedalReplacement(')
          ..write('id: $id, ')
          ..write('oldPedalId: $oldPedalId, ')
          ..write('newPedalId: $newPedalId, ')
          ..write('reason: $reason, ')
          ..write('replacedAt: $replacedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, oldPedalId, newPedalId, reason, replacedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedalReplacement &&
          other.id == this.id &&
          other.oldPedalId == this.oldPedalId &&
          other.newPedalId == this.newPedalId &&
          other.reason == this.reason &&
          other.replacedAt == this.replacedAt &&
          other.notes == this.notes);
}

class PedalReplacementsCompanion extends UpdateCompanion<PedalReplacement> {
  final Value<int> id;
  final Value<int> oldPedalId;
  final Value<int> newPedalId;
  final Value<String?> reason;
  final Value<DateTime> replacedAt;
  final Value<String?> notes;
  const PedalReplacementsCompanion({
    this.id = const Value.absent(),
    this.oldPedalId = const Value.absent(),
    this.newPedalId = const Value.absent(),
    this.reason = const Value.absent(),
    this.replacedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PedalReplacementsCompanion.insert({
    this.id = const Value.absent(),
    required int oldPedalId,
    required int newPedalId,
    this.reason = const Value.absent(),
    required DateTime replacedAt,
    this.notes = const Value.absent(),
  }) : oldPedalId = Value(oldPedalId),
       newPedalId = Value(newPedalId),
       replacedAt = Value(replacedAt);
  static Insertable<PedalReplacement> custom({
    Expression<int>? id,
    Expression<int>? oldPedalId,
    Expression<int>? newPedalId,
    Expression<String>? reason,
    Expression<DateTime>? replacedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (oldPedalId != null) 'old_pedal_id': oldPedalId,
      if (newPedalId != null) 'new_pedal_id': newPedalId,
      if (reason != null) 'reason': reason,
      if (replacedAt != null) 'replaced_at': replacedAt,
      if (notes != null) 'notes': notes,
    });
  }

  PedalReplacementsCompanion copyWith({
    Value<int>? id,
    Value<int>? oldPedalId,
    Value<int>? newPedalId,
    Value<String?>? reason,
    Value<DateTime>? replacedAt,
    Value<String?>? notes,
  }) {
    return PedalReplacementsCompanion(
      id: id ?? this.id,
      oldPedalId: oldPedalId ?? this.oldPedalId,
      newPedalId: newPedalId ?? this.newPedalId,
      reason: reason ?? this.reason,
      replacedAt: replacedAt ?? this.replacedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (oldPedalId.present) {
      map['old_pedal_id'] = Variable<int>(oldPedalId.value);
    }
    if (newPedalId.present) {
      map['new_pedal_id'] = Variable<int>(newPedalId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (replacedAt.present) {
      map['replaced_at'] = Variable<DateTime>(replacedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedalReplacementsCompanion(')
          ..write('id: $id, ')
          ..write('oldPedalId: $oldPedalId, ')
          ..write('newPedalId: $newPedalId, ')
          ..write('reason: $reason, ')
          ..write('replacedAt: $replacedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PedalboardsTable extends Pedalboards
    with TableInfo<$PedalboardsTable, Pedalboard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedalboardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedalboards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pedalboard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pedalboard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pedalboard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PedalboardsTable createAlias(String alias) {
    return $PedalboardsTable(attachedDatabase, alias);
  }
}

class Pedalboard extends DataClass implements Insertable<Pedalboard> {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Pedalboard({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PedalboardsCompanion toCompanion(bool nullToAbsent) {
    return PedalboardsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Pedalboard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pedalboard(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Pedalboard copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Pedalboard(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Pedalboard copyWithCompanion(PedalboardsCompanion data) {
    return Pedalboard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pedalboard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pedalboard &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PedalboardsCompanion extends UpdateCompanion<Pedalboard> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PedalboardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PedalboardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Pedalboard> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PedalboardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PedalboardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedalboardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SignalBlocksTable extends SignalBlocks
    with TableInfo<$SignalBlocksTable, SignalBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalboardIdMeta = const VerificationMeta(
    'pedalboardId',
  );
  @override
  late final GeneratedColumn<int> pedalboardId = GeneratedColumn<int>(
    'pedalboard_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedalboards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SignalBlockType, String>
  blockType = GeneratedColumn<String>(
    'block_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SignalBlockType>($SignalBlocksTable.$converterblockType);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalboardId,
    pedalId,
    blockType,
    label,
    position,
    isEnabled,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedalboard_id')) {
      context.handle(
        _pedalboardIdMeta,
        pedalboardId.isAcceptableOrUnknown(
          data['pedalboard_id']!,
          _pedalboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pedalboardIdMeta);
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pedalboardId, pedalId},
  ];
  @override
  SignalBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedalboard_id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      ),
      blockType: $SignalBlocksTable.$converterblockType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}block_type'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SignalBlocksTable createAlias(String alias) {
    return $SignalBlocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalBlockType, String, String>
  $converterblockType = const EnumNameConverter<SignalBlockType>(
    SignalBlockType.values,
  );
}

class SignalBlock extends DataClass implements Insertable<SignalBlock> {
  final int id;

  /// Deleting a rig deletes its blocks: a block only says what sat where on that
  /// rig, so with the rig gone there is nothing left for it to mean. The pedals
  /// themselves are untouched.
  final int pedalboardId;

  /// Restrict, like every other reference to a pedal: one that is on a rig has
  /// to be taken off it before it can be deleted.
  final int? pedalId;
  final SignalBlockType blockType;

  /// What this block is called on the board, where the pedal's own name is not
  /// what the user thinks of it as ('Always on', 'Solo boost').
  final String? label;
  final int position;

  /// Whether the block passes signal or is bypassed. A bypassed block keeps its
  /// place in the chain, because bypassing is a sound the user is trying, not a
  /// decision to take the pedal off the board.
  final bool isEnabled;
  final String? notes;
  const SignalBlock({
    required this.id,
    required this.pedalboardId,
    this.pedalId,
    required this.blockType,
    this.label,
    required this.position,
    required this.isEnabled,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedalboard_id'] = Variable<int>(pedalboardId);
    if (!nullToAbsent || pedalId != null) {
      map['pedal_id'] = Variable<int>(pedalId);
    }
    {
      map['block_type'] = Variable<String>(
        $SignalBlocksTable.$converterblockType.toSql(blockType),
      );
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['position'] = Variable<int>(position);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SignalBlocksCompanion toCompanion(bool nullToAbsent) {
    return SignalBlocksCompanion(
      id: Value(id),
      pedalboardId: Value(pedalboardId),
      pedalId: pedalId == null && nullToAbsent
          ? const Value.absent()
          : Value(pedalId),
      blockType: Value(blockType),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      position: Value(position),
      isEnabled: Value(isEnabled),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SignalBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalBlock(
      id: serializer.fromJson<int>(json['id']),
      pedalboardId: serializer.fromJson<int>(json['pedalboardId']),
      pedalId: serializer.fromJson<int?>(json['pedalId']),
      blockType: $SignalBlocksTable.$converterblockType.fromJson(
        serializer.fromJson<String>(json['blockType']),
      ),
      label: serializer.fromJson<String?>(json['label']),
      position: serializer.fromJson<int>(json['position']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalboardId': serializer.toJson<int>(pedalboardId),
      'pedalId': serializer.toJson<int?>(pedalId),
      'blockType': serializer.toJson<String>(
        $SignalBlocksTable.$converterblockType.toJson(blockType),
      ),
      'label': serializer.toJson<String?>(label),
      'position': serializer.toJson<int>(position),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SignalBlock copyWith({
    int? id,
    int? pedalboardId,
    Value<int?> pedalId = const Value.absent(),
    SignalBlockType? blockType,
    Value<String?> label = const Value.absent(),
    int? position,
    bool? isEnabled,
    Value<String?> notes = const Value.absent(),
  }) => SignalBlock(
    id: id ?? this.id,
    pedalboardId: pedalboardId ?? this.pedalboardId,
    pedalId: pedalId.present ? pedalId.value : this.pedalId,
    blockType: blockType ?? this.blockType,
    label: label.present ? label.value : this.label,
    position: position ?? this.position,
    isEnabled: isEnabled ?? this.isEnabled,
    notes: notes.present ? notes.value : this.notes,
  );
  SignalBlock copyWithCompanion(SignalBlocksCompanion data) {
    return SignalBlock(
      id: data.id.present ? data.id.value : this.id,
      pedalboardId: data.pedalboardId.present
          ? data.pedalboardId.value
          : this.pedalboardId,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      blockType: data.blockType.present ? data.blockType.value : this.blockType,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalBlock(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('pedalId: $pedalId, ')
          ..write('blockType: $blockType, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pedalboardId,
    pedalId,
    blockType,
    label,
    position,
    isEnabled,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalBlock &&
          other.id == this.id &&
          other.pedalboardId == this.pedalboardId &&
          other.pedalId == this.pedalId &&
          other.blockType == this.blockType &&
          other.label == this.label &&
          other.position == this.position &&
          other.isEnabled == this.isEnabled &&
          other.notes == this.notes);
}

class SignalBlocksCompanion extends UpdateCompanion<SignalBlock> {
  final Value<int> id;
  final Value<int> pedalboardId;
  final Value<int?> pedalId;
  final Value<SignalBlockType> blockType;
  final Value<String?> label;
  final Value<int> position;
  final Value<bool> isEnabled;
  final Value<String?> notes;
  const SignalBlocksCompanion({
    this.id = const Value.absent(),
    this.pedalboardId = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.blockType = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SignalBlocksCompanion.insert({
    this.id = const Value.absent(),
    required int pedalboardId,
    this.pedalId = const Value.absent(),
    required SignalBlockType blockType,
    this.label = const Value.absent(),
    required int position,
    this.isEnabled = const Value.absent(),
    this.notes = const Value.absent(),
  }) : pedalboardId = Value(pedalboardId),
       blockType = Value(blockType),
       position = Value(position);
  static Insertable<SignalBlock> custom({
    Expression<int>? id,
    Expression<int>? pedalboardId,
    Expression<int>? pedalId,
    Expression<String>? blockType,
    Expression<String>? label,
    Expression<int>? position,
    Expression<bool>? isEnabled,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalboardId != null) 'pedalboard_id': pedalboardId,
      if (pedalId != null) 'pedal_id': pedalId,
      if (blockType != null) 'block_type': blockType,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (notes != null) 'notes': notes,
    });
  }

  SignalBlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalboardId,
    Value<int?>? pedalId,
    Value<SignalBlockType>? blockType,
    Value<String?>? label,
    Value<int>? position,
    Value<bool>? isEnabled,
    Value<String?>? notes,
  }) {
    return SignalBlocksCompanion(
      id: id ?? this.id,
      pedalboardId: pedalboardId ?? this.pedalboardId,
      pedalId: pedalId ?? this.pedalId,
      blockType: blockType ?? this.blockType,
      label: label ?? this.label,
      position: position ?? this.position,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalboardId.present) {
      map['pedalboard_id'] = Variable<int>(pedalboardId.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (blockType.present) {
      map['block_type'] = Variable<String>(
        $SignalBlocksTable.$converterblockType.toSql(blockType.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalBlocksCompanion(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('pedalId: $pedalId, ')
          ..write('blockType: $blockType, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SignalConnectionsTable extends SignalConnections
    with TableInfo<$SignalConnectionsTable, SignalConnection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalboardIdMeta = const VerificationMeta(
    'pedalboardId',
  );
  @override
  late final GeneratedColumn<int> pedalboardId = GeneratedColumn<int>(
    'pedalboard_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedalboards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceBlockIdMeta = const VerificationMeta(
    'sourceBlockId',
  );
  @override
  late final GeneratedColumn<int> sourceBlockId = GeneratedColumn<int>(
    'source_block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal_blocks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetBlockIdMeta = const VerificationMeta(
    'targetBlockId',
  );
  @override
  late final GeneratedColumn<int> targetBlockId = GeneratedColumn<int>(
    'target_block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal_blocks (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SignalConnectionType, String>
  connectionType =
      GeneratedColumn<String>(
        'connection_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SignalConnectionType>(
        $SignalConnectionsTable.$converterconnectionType,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalboardId,
    sourceBlockId,
    targetBlockId,
    connectionType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalConnection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedalboard_id')) {
      context.handle(
        _pedalboardIdMeta,
        pedalboardId.isAcceptableOrUnknown(
          data['pedalboard_id']!,
          _pedalboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pedalboardIdMeta);
    }
    if (data.containsKey('source_block_id')) {
      context.handle(
        _sourceBlockIdMeta,
        sourceBlockId.isAcceptableOrUnknown(
          data['source_block_id']!,
          _sourceBlockIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceBlockIdMeta);
    }
    if (data.containsKey('target_block_id')) {
      context.handle(
        _targetBlockIdMeta,
        targetBlockId.isAcceptableOrUnknown(
          data['target_block_id']!,
          _targetBlockIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetBlockIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceBlockId, targetBlockId},
  ];
  @override
  SignalConnection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalConnection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedalboard_id'],
      )!,
      sourceBlockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_block_id'],
      )!,
      targetBlockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_block_id'],
      )!,
      connectionType: $SignalConnectionsTable.$converterconnectionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}connection_type'],
        )!,
      ),
    );
  }

  @override
  $SignalConnectionsTable createAlias(String alias) {
    return $SignalConnectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalConnectionType, String, String>
  $converterconnectionType = const EnumNameConverter<SignalConnectionType>(
    SignalConnectionType.values,
  );
}

class SignalConnection extends DataClass
    implements Insertable<SignalConnection> {
  final int id;
  final int pedalboardId;

  /// Cascade both ways: a cable to a block that is gone is not a cable, so
  /// removing a block takes its connections with it rather than refusing.
  ///
  /// Both ends name the same table, so each is named for the direction it looks
  /// in; without that drift cannot tell the two apart.
  final int sourceBlockId;
  final int targetBlockId;
  final SignalConnectionType connectionType;
  const SignalConnection({
    required this.id,
    required this.pedalboardId,
    required this.sourceBlockId,
    required this.targetBlockId,
    required this.connectionType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedalboard_id'] = Variable<int>(pedalboardId);
    map['source_block_id'] = Variable<int>(sourceBlockId);
    map['target_block_id'] = Variable<int>(targetBlockId);
    {
      map['connection_type'] = Variable<String>(
        $SignalConnectionsTable.$converterconnectionType.toSql(connectionType),
      );
    }
    return map;
  }

  SignalConnectionsCompanion toCompanion(bool nullToAbsent) {
    return SignalConnectionsCompanion(
      id: Value(id),
      pedalboardId: Value(pedalboardId),
      sourceBlockId: Value(sourceBlockId),
      targetBlockId: Value(targetBlockId),
      connectionType: Value(connectionType),
    );
  }

  factory SignalConnection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalConnection(
      id: serializer.fromJson<int>(json['id']),
      pedalboardId: serializer.fromJson<int>(json['pedalboardId']),
      sourceBlockId: serializer.fromJson<int>(json['sourceBlockId']),
      targetBlockId: serializer.fromJson<int>(json['targetBlockId']),
      connectionType: $SignalConnectionsTable.$converterconnectionType.fromJson(
        serializer.fromJson<String>(json['connectionType']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalboardId': serializer.toJson<int>(pedalboardId),
      'sourceBlockId': serializer.toJson<int>(sourceBlockId),
      'targetBlockId': serializer.toJson<int>(targetBlockId),
      'connectionType': serializer.toJson<String>(
        $SignalConnectionsTable.$converterconnectionType.toJson(connectionType),
      ),
    };
  }

  SignalConnection copyWith({
    int? id,
    int? pedalboardId,
    int? sourceBlockId,
    int? targetBlockId,
    SignalConnectionType? connectionType,
  }) => SignalConnection(
    id: id ?? this.id,
    pedalboardId: pedalboardId ?? this.pedalboardId,
    sourceBlockId: sourceBlockId ?? this.sourceBlockId,
    targetBlockId: targetBlockId ?? this.targetBlockId,
    connectionType: connectionType ?? this.connectionType,
  );
  SignalConnection copyWithCompanion(SignalConnectionsCompanion data) {
    return SignalConnection(
      id: data.id.present ? data.id.value : this.id,
      pedalboardId: data.pedalboardId.present
          ? data.pedalboardId.value
          : this.pedalboardId,
      sourceBlockId: data.sourceBlockId.present
          ? data.sourceBlockId.value
          : this.sourceBlockId,
      targetBlockId: data.targetBlockId.present
          ? data.targetBlockId.value
          : this.targetBlockId,
      connectionType: data.connectionType.present
          ? data.connectionType.value
          : this.connectionType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalConnection(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('sourceBlockId: $sourceBlockId, ')
          ..write('targetBlockId: $targetBlockId, ')
          ..write('connectionType: $connectionType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pedalboardId,
    sourceBlockId,
    targetBlockId,
    connectionType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalConnection &&
          other.id == this.id &&
          other.pedalboardId == this.pedalboardId &&
          other.sourceBlockId == this.sourceBlockId &&
          other.targetBlockId == this.targetBlockId &&
          other.connectionType == this.connectionType);
}

class SignalConnectionsCompanion extends UpdateCompanion<SignalConnection> {
  final Value<int> id;
  final Value<int> pedalboardId;
  final Value<int> sourceBlockId;
  final Value<int> targetBlockId;
  final Value<SignalConnectionType> connectionType;
  const SignalConnectionsCompanion({
    this.id = const Value.absent(),
    this.pedalboardId = const Value.absent(),
    this.sourceBlockId = const Value.absent(),
    this.targetBlockId = const Value.absent(),
    this.connectionType = const Value.absent(),
  });
  SignalConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required int pedalboardId,
    required int sourceBlockId,
    required int targetBlockId,
    required SignalConnectionType connectionType,
  }) : pedalboardId = Value(pedalboardId),
       sourceBlockId = Value(sourceBlockId),
       targetBlockId = Value(targetBlockId),
       connectionType = Value(connectionType);
  static Insertable<SignalConnection> custom({
    Expression<int>? id,
    Expression<int>? pedalboardId,
    Expression<int>? sourceBlockId,
    Expression<int>? targetBlockId,
    Expression<String>? connectionType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalboardId != null) 'pedalboard_id': pedalboardId,
      if (sourceBlockId != null) 'source_block_id': sourceBlockId,
      if (targetBlockId != null) 'target_block_id': targetBlockId,
      if (connectionType != null) 'connection_type': connectionType,
    });
  }

  SignalConnectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalboardId,
    Value<int>? sourceBlockId,
    Value<int>? targetBlockId,
    Value<SignalConnectionType>? connectionType,
  }) {
    return SignalConnectionsCompanion(
      id: id ?? this.id,
      pedalboardId: pedalboardId ?? this.pedalboardId,
      sourceBlockId: sourceBlockId ?? this.sourceBlockId,
      targetBlockId: targetBlockId ?? this.targetBlockId,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalboardId.present) {
      map['pedalboard_id'] = Variable<int>(pedalboardId.value);
    }
    if (sourceBlockId.present) {
      map['source_block_id'] = Variable<int>(sourceBlockId.value);
    }
    if (targetBlockId.present) {
      map['target_block_id'] = Variable<int>(targetBlockId.value);
    }
    if (connectionType.present) {
      map['connection_type'] = Variable<String>(
        $SignalConnectionsTable.$converterconnectionType.toSql(
          connectionType.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('sourceBlockId: $sourceBlockId, ')
          ..write('targetBlockId: $targetBlockId, ')
          ..write('connectionType: $connectionType')
          ..write(')'))
        .toString();
  }
}

class $SignalEndpointsTable extends SignalEndpoints
    with TableInfo<$SignalEndpointsTable, SignalEndpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalEndpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _blockIdMeta = const VerificationMeta(
    'blockId',
  );
  @override
  late final GeneratedColumn<int> blockId = GeneratedColumn<int>(
    'block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal_blocks (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SignalDestination?, String>
  destination =
      GeneratedColumn<String>(
        'destination',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SignalDestination?>(
        $SignalEndpointsTable.$converterdestinationn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SignalSource?, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SignalSource?>($SignalEndpointsTable.$convertersourcen);
  static const VerificationMeta _pairedBlockIdMeta = const VerificationMeta(
    'pairedBlockId',
  );
  @override
  late final GeneratedColumn<int> pairedBlockId = GeneratedColumn<int>(
    'paired_block_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal_blocks (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _gearMeta = const VerificationMeta('gear');
  @override
  late final GeneratedColumn<String> gear = GeneratedColumn<String>(
    'gear',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    blockId,
    destination,
    source,
    pairedBlockId,
    gear,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_endpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalEndpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('block_id')) {
      context.handle(
        _blockIdMeta,
        blockId.isAcceptableOrUnknown(data['block_id']!, _blockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_blockIdMeta);
    }
    if (data.containsKey('paired_block_id')) {
      context.handle(
        _pairedBlockIdMeta,
        pairedBlockId.isAcceptableOrUnknown(
          data['paired_block_id']!,
          _pairedBlockIdMeta,
        ),
      );
    }
    if (data.containsKey('gear')) {
      context.handle(
        _gearMeta,
        gear.isAcceptableOrUnknown(data['gear']!, _gearMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {blockId},
  ];
  @override
  SignalEndpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalEndpoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      blockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_id'],
      )!,
      destination: $SignalEndpointsTable.$converterdestinationn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destination'],
        ),
      ),
      source: $SignalEndpointsTable.$convertersourcen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        ),
      ),
      pairedBlockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paired_block_id'],
      ),
      gear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SignalEndpointsTable createAlias(String alias) {
    return $SignalEndpointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalDestination, String, String>
  $converterdestination = const EnumNameConverter<SignalDestination>(
    SignalDestination.values,
  );
  static JsonTypeConverter2<SignalDestination?, String?, String?>
  $converterdestinationn = JsonTypeConverter2.asNullable($converterdestination);
  static JsonTypeConverter2<SignalSource, String, String> $convertersource =
      const EnumNameConverter<SignalSource>(SignalSource.values);
  static JsonTypeConverter2<SignalSource?, String?, String?> $convertersourcen =
      JsonTypeConverter2.asNullable($convertersource);
}

class SignalEndpoint extends DataClass implements Insertable<SignalEndpoint> {
  final int id;

  /// Cascade: what a block reaches is only a fact about that block, so with the
  /// block gone there is nothing left for the row to describe.
  final int blockId;
  final SignalDestination? destination;
  final SignalSource? source;

  /// Set null rather than cascade: losing the return does not make the send stop
  /// existing, it makes it a send with nothing coming back yet.
  final int? pairedBlockId;

  /// What is actually at the other end, in the user's own words: 'Marshall JVM,
  /// channel 2', 'the desk on stage left'.
  final String? gear;
  final String? notes;
  const SignalEndpoint({
    required this.id,
    required this.blockId,
    this.destination,
    this.source,
    this.pairedBlockId,
    this.gear,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['block_id'] = Variable<int>(blockId);
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(
        $SignalEndpointsTable.$converterdestinationn.toSql(destination),
      );
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(
        $SignalEndpointsTable.$convertersourcen.toSql(source),
      );
    }
    if (!nullToAbsent || pairedBlockId != null) {
      map['paired_block_id'] = Variable<int>(pairedBlockId);
    }
    if (!nullToAbsent || gear != null) {
      map['gear'] = Variable<String>(gear);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SignalEndpointsCompanion toCompanion(bool nullToAbsent) {
    return SignalEndpointsCompanion(
      id: Value(id),
      blockId: Value(blockId),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      pairedBlockId: pairedBlockId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedBlockId),
      gear: gear == null && nullToAbsent ? const Value.absent() : Value(gear),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SignalEndpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalEndpoint(
      id: serializer.fromJson<int>(json['id']),
      blockId: serializer.fromJson<int>(json['blockId']),
      destination: $SignalEndpointsTable.$converterdestinationn.fromJson(
        serializer.fromJson<String?>(json['destination']),
      ),
      source: $SignalEndpointsTable.$convertersourcen.fromJson(
        serializer.fromJson<String?>(json['source']),
      ),
      pairedBlockId: serializer.fromJson<int?>(json['pairedBlockId']),
      gear: serializer.fromJson<String?>(json['gear']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'blockId': serializer.toJson<int>(blockId),
      'destination': serializer.toJson<String?>(
        $SignalEndpointsTable.$converterdestinationn.toJson(destination),
      ),
      'source': serializer.toJson<String?>(
        $SignalEndpointsTable.$convertersourcen.toJson(source),
      ),
      'pairedBlockId': serializer.toJson<int?>(pairedBlockId),
      'gear': serializer.toJson<String?>(gear),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SignalEndpoint copyWith({
    int? id,
    int? blockId,
    Value<SignalDestination?> destination = const Value.absent(),
    Value<SignalSource?> source = const Value.absent(),
    Value<int?> pairedBlockId = const Value.absent(),
    Value<String?> gear = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SignalEndpoint(
    id: id ?? this.id,
    blockId: blockId ?? this.blockId,
    destination: destination.present ? destination.value : this.destination,
    source: source.present ? source.value : this.source,
    pairedBlockId: pairedBlockId.present
        ? pairedBlockId.value
        : this.pairedBlockId,
    gear: gear.present ? gear.value : this.gear,
    notes: notes.present ? notes.value : this.notes,
  );
  SignalEndpoint copyWithCompanion(SignalEndpointsCompanion data) {
    return SignalEndpoint(
      id: data.id.present ? data.id.value : this.id,
      blockId: data.blockId.present ? data.blockId.value : this.blockId,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      source: data.source.present ? data.source.value : this.source,
      pairedBlockId: data.pairedBlockId.present
          ? data.pairedBlockId.value
          : this.pairedBlockId,
      gear: data.gear.present ? data.gear.value : this.gear,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalEndpoint(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('destination: $destination, ')
          ..write('source: $source, ')
          ..write('pairedBlockId: $pairedBlockId, ')
          ..write('gear: $gear, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, blockId, destination, source, pairedBlockId, gear, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalEndpoint &&
          other.id == this.id &&
          other.blockId == this.blockId &&
          other.destination == this.destination &&
          other.source == this.source &&
          other.pairedBlockId == this.pairedBlockId &&
          other.gear == this.gear &&
          other.notes == this.notes);
}

class SignalEndpointsCompanion extends UpdateCompanion<SignalEndpoint> {
  final Value<int> id;
  final Value<int> blockId;
  final Value<SignalDestination?> destination;
  final Value<SignalSource?> source;
  final Value<int?> pairedBlockId;
  final Value<String?> gear;
  final Value<String?> notes;
  const SignalEndpointsCompanion({
    this.id = const Value.absent(),
    this.blockId = const Value.absent(),
    this.destination = const Value.absent(),
    this.source = const Value.absent(),
    this.pairedBlockId = const Value.absent(),
    this.gear = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SignalEndpointsCompanion.insert({
    this.id = const Value.absent(),
    required int blockId,
    this.destination = const Value.absent(),
    this.source = const Value.absent(),
    this.pairedBlockId = const Value.absent(),
    this.gear = const Value.absent(),
    this.notes = const Value.absent(),
  }) : blockId = Value(blockId);
  static Insertable<SignalEndpoint> custom({
    Expression<int>? id,
    Expression<int>? blockId,
    Expression<String>? destination,
    Expression<String>? source,
    Expression<int>? pairedBlockId,
    Expression<String>? gear,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blockId != null) 'block_id': blockId,
      if (destination != null) 'destination': destination,
      if (source != null) 'source': source,
      if (pairedBlockId != null) 'paired_block_id': pairedBlockId,
      if (gear != null) 'gear': gear,
      if (notes != null) 'notes': notes,
    });
  }

  SignalEndpointsCompanion copyWith({
    Value<int>? id,
    Value<int>? blockId,
    Value<SignalDestination?>? destination,
    Value<SignalSource?>? source,
    Value<int?>? pairedBlockId,
    Value<String?>? gear,
    Value<String?>? notes,
  }) {
    return SignalEndpointsCompanion(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      destination: destination ?? this.destination,
      source: source ?? this.source,
      pairedBlockId: pairedBlockId ?? this.pairedBlockId,
      gear: gear ?? this.gear,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (blockId.present) {
      map['block_id'] = Variable<int>(blockId.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(
        $SignalEndpointsTable.$converterdestinationn.toSql(destination.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $SignalEndpointsTable.$convertersourcen.toSql(source.value),
      );
    }
    if (pairedBlockId.present) {
      map['paired_block_id'] = Variable<int>(pairedBlockId.value);
    }
    if (gear.present) {
      map['gear'] = Variable<String>(gear.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalEndpointsCompanion(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('destination: $destination, ')
          ..write('source: $source, ')
          ..write('pairedBlockId: $pairedBlockId, ')
          ..write('gear: $gear, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RigSnapshotsTable extends RigSnapshots
    with TableInfo<$RigSnapshotsTable, RigSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RigSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedalboardIdMeta = const VerificationMeta(
    'pedalboardId',
  );
  @override
  late final GeneratedColumn<int> pedalboardId = GeneratedColumn<int>(
    'pedalboard_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedalboards (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointSummaryMeta = const VerificationMeta(
    'endpointSummary',
  );
  @override
  late final GeneratedColumn<String> endpointSummary = GeneratedColumn<String>(
    'endpoint_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedalboardId,
    name,
    notes,
    capturedAt,
    endpointSummary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rig_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<RigSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedalboard_id')) {
      context.handle(
        _pedalboardIdMeta,
        pedalboardId.isAcceptableOrUnknown(
          data['pedalboard_id']!,
          _pedalboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pedalboardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('endpoint_summary')) {
      context.handle(
        _endpointSummaryMeta,
        endpointSummary.isAcceptableOrUnknown(
          data['endpoint_summary']!,
          _endpointSummaryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RigSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RigSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedalboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedalboard_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      endpointSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint_summary'],
      ),
    );
  }

  @override
  $RigSnapshotsTable createAlias(String alias) {
    return $RigSnapshotsTable(attachedDatabase, alias);
  }
}

class RigSnapshot extends DataClass implements Insertable<RigSnapshot> {
  final int id;
  final int pedalboardId;
  final String name;
  final String? notes;

  /// When the rig looked like this, which is the snapshot's whole point and so
  /// is never rewritten. The name and notes stay editable.
  final DateTime capturedAt;

  /// Where the rig reached at either end that day, one line per edge, in the
  /// words the chain read.
  ///
  /// Copied as text for the reason [RigSnapshotEntries.configurationName] is: the
  /// blocks that said it can be rewired the next morning, and a record that
  /// changed with them would not be a record. Null on a rig that never said which
  /// amp or desk it ran into, which is most rigs.
  final String? endpointSummary;
  const RigSnapshot({
    required this.id,
    required this.pedalboardId,
    required this.name,
    this.notes,
    required this.capturedAt,
    this.endpointSummary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedalboard_id'] = Variable<int>(pedalboardId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || endpointSummary != null) {
      map['endpoint_summary'] = Variable<String>(endpointSummary);
    }
    return map;
  }

  RigSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return RigSnapshotsCompanion(
      id: Value(id),
      pedalboardId: Value(pedalboardId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      capturedAt: Value(capturedAt),
      endpointSummary: endpointSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(endpointSummary),
    );
  }

  factory RigSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RigSnapshot(
      id: serializer.fromJson<int>(json['id']),
      pedalboardId: serializer.fromJson<int>(json['pedalboardId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      endpointSummary: serializer.fromJson<String?>(json['endpointSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedalboardId': serializer.toJson<int>(pedalboardId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'endpointSummary': serializer.toJson<String?>(endpointSummary),
    };
  }

  RigSnapshot copyWith({
    int? id,
    int? pedalboardId,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? capturedAt,
    Value<String?> endpointSummary = const Value.absent(),
  }) => RigSnapshot(
    id: id ?? this.id,
    pedalboardId: pedalboardId ?? this.pedalboardId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    capturedAt: capturedAt ?? this.capturedAt,
    endpointSummary: endpointSummary.present
        ? endpointSummary.value
        : this.endpointSummary,
  );
  RigSnapshot copyWithCompanion(RigSnapshotsCompanion data) {
    return RigSnapshot(
      id: data.id.present ? data.id.value : this.id,
      pedalboardId: data.pedalboardId.present
          ? data.pedalboardId.value
          : this.pedalboardId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      endpointSummary: data.endpointSummary.present
          ? data.endpointSummary.value
          : this.endpointSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshot(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('endpointSummary: $endpointSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pedalboardId, name, notes, capturedAt, endpointSummary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RigSnapshot &&
          other.id == this.id &&
          other.pedalboardId == this.pedalboardId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.capturedAt == this.capturedAt &&
          other.endpointSummary == this.endpointSummary);
}

class RigSnapshotsCompanion extends UpdateCompanion<RigSnapshot> {
  final Value<int> id;
  final Value<int> pedalboardId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> capturedAt;
  final Value<String?> endpointSummary;
  const RigSnapshotsCompanion({
    this.id = const Value.absent(),
    this.pedalboardId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.endpointSummary = const Value.absent(),
  });
  RigSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int pedalboardId,
    required String name,
    this.notes = const Value.absent(),
    required DateTime capturedAt,
    this.endpointSummary = const Value.absent(),
  }) : pedalboardId = Value(pedalboardId),
       name = Value(name),
       capturedAt = Value(capturedAt);
  static Insertable<RigSnapshot> custom({
    Expression<int>? id,
    Expression<int>? pedalboardId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? capturedAt,
    Expression<String>? endpointSummary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedalboardId != null) 'pedalboard_id': pedalboardId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (endpointSummary != null) 'endpoint_summary': endpointSummary,
    });
  }

  RigSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? pedalboardId,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? capturedAt,
    Value<String?>? endpointSummary,
  }) {
    return RigSnapshotsCompanion(
      id: id ?? this.id,
      pedalboardId: pedalboardId ?? this.pedalboardId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      capturedAt: capturedAt ?? this.capturedAt,
      endpointSummary: endpointSummary ?? this.endpointSummary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedalboardId.present) {
      map['pedalboard_id'] = Variable<int>(pedalboardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (endpointSummary.present) {
      map['endpoint_summary'] = Variable<String>(endpointSummary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('pedalboardId: $pedalboardId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('endpointSummary: $endpointSummary')
          ..write(')'))
        .toString();
  }
}

class $RigSnapshotEntriesTable extends RigSnapshotEntries
    with TableInfo<$RigSnapshotEntriesTable, RigSnapshotEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RigSnapshotEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<int> snapshotId = GeneratedColumn<int>(
    'snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rig_snapshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pedalIdMeta = const VerificationMeta(
    'pedalId',
  );
  @override
  late final GeneratedColumn<int> pedalId = GeneratedColumn<int>(
    'pedal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configurationNameMeta = const VerificationMeta(
    'configurationName',
  );
  @override
  late final GeneratedColumn<String> configurationName =
      GeneratedColumn<String>(
        'configuration_name',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 80,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    snapshotId,
    pedalId,
    position,
    configurationName,
    isEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rig_snapshot_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RigSnapshotEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotIdMeta);
    }
    if (data.containsKey('pedal_id')) {
      context.handle(
        _pedalIdMeta,
        pedalId.isAcceptableOrUnknown(data['pedal_id']!, _pedalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedalIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('configuration_name')) {
      context.handle(
        _configurationNameMeta,
        configurationName.isAcceptableOrUnknown(
          data['configuration_name']!,
          _configurationNameMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {snapshotId, pedalId},
  ];
  @override
  RigSnapshotEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RigSnapshotEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_id'],
      )!,
      pedalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pedal_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      configurationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_name'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $RigSnapshotEntriesTable createAlias(String alias) {
    return $RigSnapshotEntriesTable(attachedDatabase, alias);
  }
}

class RigSnapshotEntry extends DataClass
    implements Insertable<RigSnapshotEntry> {
  final int id;
  final int snapshotId;
  final int pedalId;

  /// Zero-based, in the order signal reached it, exactly as the chain read.
  final int position;
  final String? configurationName;

  /// Whether the pedal was passing signal that day, or stood on the board with
  /// its footswitch off. A bypassed pedal is part of what was played - it was set
  /// up that way and reached for mid-song - so it is recorded rather than left
  /// out, and true is what every entry taken before this was recorded meant.
  final bool isEnabled;
  const RigSnapshotEntry({
    required this.id,
    required this.snapshotId,
    required this.pedalId,
    required this.position,
    this.configurationName,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['snapshot_id'] = Variable<int>(snapshotId);
    map['pedal_id'] = Variable<int>(pedalId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || configurationName != null) {
      map['configuration_name'] = Variable<String>(configurationName);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  RigSnapshotEntriesCompanion toCompanion(bool nullToAbsent) {
    return RigSnapshotEntriesCompanion(
      id: Value(id),
      snapshotId: Value(snapshotId),
      pedalId: Value(pedalId),
      position: Value(position),
      configurationName: configurationName == null && nullToAbsent
          ? const Value.absent()
          : Value(configurationName),
      isEnabled: Value(isEnabled),
    );
  }

  factory RigSnapshotEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RigSnapshotEntry(
      id: serializer.fromJson<int>(json['id']),
      snapshotId: serializer.fromJson<int>(json['snapshotId']),
      pedalId: serializer.fromJson<int>(json['pedalId']),
      position: serializer.fromJson<int>(json['position']),
      configurationName: serializer.fromJson<String?>(
        json['configurationName'],
      ),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'snapshotId': serializer.toJson<int>(snapshotId),
      'pedalId': serializer.toJson<int>(pedalId),
      'position': serializer.toJson<int>(position),
      'configurationName': serializer.toJson<String?>(configurationName),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  RigSnapshotEntry copyWith({
    int? id,
    int? snapshotId,
    int? pedalId,
    int? position,
    Value<String?> configurationName = const Value.absent(),
    bool? isEnabled,
  }) => RigSnapshotEntry(
    id: id ?? this.id,
    snapshotId: snapshotId ?? this.snapshotId,
    pedalId: pedalId ?? this.pedalId,
    position: position ?? this.position,
    configurationName: configurationName.present
        ? configurationName.value
        : this.configurationName,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  RigSnapshotEntry copyWithCompanion(RigSnapshotEntriesCompanion data) {
    return RigSnapshotEntry(
      id: data.id.present ? data.id.value : this.id,
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      pedalId: data.pedalId.present ? data.pedalId.value : this.pedalId,
      position: data.position.present ? data.position.value : this.position,
      configurationName: data.configurationName.present
          ? data.configurationName.value
          : this.configurationName,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshotEntry(')
          ..write('id: $id, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('pedalId: $pedalId, ')
          ..write('position: $position, ')
          ..write('configurationName: $configurationName, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    snapshotId,
    pedalId,
    position,
    configurationName,
    isEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RigSnapshotEntry &&
          other.id == this.id &&
          other.snapshotId == this.snapshotId &&
          other.pedalId == this.pedalId &&
          other.position == this.position &&
          other.configurationName == this.configurationName &&
          other.isEnabled == this.isEnabled);
}

class RigSnapshotEntriesCompanion extends UpdateCompanion<RigSnapshotEntry> {
  final Value<int> id;
  final Value<int> snapshotId;
  final Value<int> pedalId;
  final Value<int> position;
  final Value<String?> configurationName;
  final Value<bool> isEnabled;
  const RigSnapshotEntriesCompanion({
    this.id = const Value.absent(),
    this.snapshotId = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.position = const Value.absent(),
    this.configurationName = const Value.absent(),
    this.isEnabled = const Value.absent(),
  });
  RigSnapshotEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int snapshotId,
    required int pedalId,
    required int position,
    this.configurationName = const Value.absent(),
    this.isEnabled = const Value.absent(),
  }) : snapshotId = Value(snapshotId),
       pedalId = Value(pedalId),
       position = Value(position);
  static Insertable<RigSnapshotEntry> custom({
    Expression<int>? id,
    Expression<int>? snapshotId,
    Expression<int>? pedalId,
    Expression<int>? position,
    Expression<String>? configurationName,
    Expression<bool>? isEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (pedalId != null) 'pedal_id': pedalId,
      if (position != null) 'position': position,
      if (configurationName != null) 'configuration_name': configurationName,
      if (isEnabled != null) 'is_enabled': isEnabled,
    });
  }

  RigSnapshotEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? snapshotId,
    Value<int>? pedalId,
    Value<int>? position,
    Value<String?>? configurationName,
    Value<bool>? isEnabled,
  }) {
    return RigSnapshotEntriesCompanion(
      id: id ?? this.id,
      snapshotId: snapshotId ?? this.snapshotId,
      pedalId: pedalId ?? this.pedalId,
      position: position ?? this.position,
      configurationName: configurationName ?? this.configurationName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<int>(snapshotId.value);
    }
    if (pedalId.present) {
      map['pedal_id'] = Variable<int>(pedalId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (configurationName.present) {
      map['configuration_name'] = Variable<String>(configurationName.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshotEntriesCompanion(')
          ..write('id: $id, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('pedalId: $pedalId, ')
          ..write('position: $position, ')
          ..write('configurationName: $configurationName, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }
}

class $RigSnapshotValuesTable extends RigSnapshotValues
    with TableInfo<$RigSnapshotValuesTable, RigSnapshotValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RigSnapshotValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rig_snapshot_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _controlNameMeta = const VerificationMeta(
    'controlName',
  );
  @override
  late final GeneratedColumn<String> controlName = GeneratedColumn<String>(
    'control_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controlPedalNameMeta = const VerificationMeta(
    'controlPedalName',
  );
  @override
  late final GeneratedColumn<String> controlPedalName = GeneratedColumn<String>(
    'control_pedal_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ControlType, String> controlType =
      GeneratedColumn<String>(
        'control_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ControlType>(
        $RigSnapshotValuesTable.$convertercontrolType,
      );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 12,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    controlName,
    controlPedalName,
    controlType,
    value,
    unit,
    options,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rig_snapshot_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<RigSnapshotValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('control_name')) {
      context.handle(
        _controlNameMeta,
        controlName.isAcceptableOrUnknown(
          data['control_name']!,
          _controlNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_controlNameMeta);
    }
    if (data.containsKey('control_pedal_name')) {
      context.handle(
        _controlPedalNameMeta,
        controlPedalName.isAcceptableOrUnknown(
          data['control_pedal_name']!,
          _controlPedalNameMeta,
        ),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entryId, controlPedalName, controlName},
  ];
  @override
  RigSnapshotValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RigSnapshotValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      controlName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_name'],
      )!,
      controlPedalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_pedal_name'],
      ),
      controlType: $RigSnapshotValuesTable.$convertercontrolType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}control_type'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $RigSnapshotValuesTable createAlias(String alias) {
    return $RigSnapshotValuesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ControlType, String, String> $convertercontrolType =
      const EnumNameConverter<ControlType>(ControlType.values);
}

class RigSnapshotValue extends DataClass
    implements Insertable<RigSnapshotValue> {
  final int id;
  final int entryId;
  final String controlName;

  /// The pedal the knob was on, as that pedal was called that day.
  ///
  /// Set on every reading written since it was added. It is what tells two knobs
  /// apart when a multi-effects unit is captured on one of its scenes: the entry
  /// is the unit, but the knobs belong to the pedals inside it, and "Level at
  /// 2:30" says nothing when three of them have a Level.
  ///
  /// Null on readings written before the column existed, which were all one
  /// pedal's own: null reads as the pedal the entry is filed under.
  final String? controlPedalName;
  final ControlType controlType;
  final double value;
  final String? unit;

  /// Position names of a selection control as they read that day, as a JSON
  /// array of strings. Null for every other control type.
  final String? options;
  final int displayOrder;
  const RigSnapshotValue({
    required this.id,
    required this.entryId,
    required this.controlName,
    this.controlPedalName,
    required this.controlType,
    required this.value,
    this.unit,
    this.options,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['control_name'] = Variable<String>(controlName);
    if (!nullToAbsent || controlPedalName != null) {
      map['control_pedal_name'] = Variable<String>(controlPedalName);
    }
    {
      map['control_type'] = Variable<String>(
        $RigSnapshotValuesTable.$convertercontrolType.toSql(controlType),
      );
    }
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  RigSnapshotValuesCompanion toCompanion(bool nullToAbsent) {
    return RigSnapshotValuesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      controlName: Value(controlName),
      controlPedalName: controlPedalName == null && nullToAbsent
          ? const Value.absent()
          : Value(controlPedalName),
      controlType: Value(controlType),
      value: Value(value),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      displayOrder: Value(displayOrder),
    );
  }

  factory RigSnapshotValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RigSnapshotValue(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      controlName: serializer.fromJson<String>(json['controlName']),
      controlPedalName: serializer.fromJson<String?>(json['controlPedalName']),
      controlType: $RigSnapshotValuesTable.$convertercontrolType.fromJson(
        serializer.fromJson<String>(json['controlType']),
      ),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String?>(json['unit']),
      options: serializer.fromJson<String?>(json['options']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'controlName': serializer.toJson<String>(controlName),
      'controlPedalName': serializer.toJson<String?>(controlPedalName),
      'controlType': serializer.toJson<String>(
        $RigSnapshotValuesTable.$convertercontrolType.toJson(controlType),
      ),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String?>(unit),
      'options': serializer.toJson<String?>(options),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  RigSnapshotValue copyWith({
    int? id,
    int? entryId,
    String? controlName,
    Value<String?> controlPedalName = const Value.absent(),
    ControlType? controlType,
    double? value,
    Value<String?> unit = const Value.absent(),
    Value<String?> options = const Value.absent(),
    int? displayOrder,
  }) => RigSnapshotValue(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    controlName: controlName ?? this.controlName,
    controlPedalName: controlPedalName.present
        ? controlPedalName.value
        : this.controlPedalName,
    controlType: controlType ?? this.controlType,
    value: value ?? this.value,
    unit: unit.present ? unit.value : this.unit,
    options: options.present ? options.value : this.options,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  RigSnapshotValue copyWithCompanion(RigSnapshotValuesCompanion data) {
    return RigSnapshotValue(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      controlName: data.controlName.present
          ? data.controlName.value
          : this.controlName,
      controlPedalName: data.controlPedalName.present
          ? data.controlPedalName.value
          : this.controlPedalName,
      controlType: data.controlType.present
          ? data.controlType.value
          : this.controlType,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      options: data.options.present ? data.options.value : this.options,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshotValue(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('controlName: $controlName, ')
          ..write('controlPedalName: $controlPedalName, ')
          ..write('controlType: $controlType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('options: $options, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    controlName,
    controlPedalName,
    controlType,
    value,
    unit,
    options,
    displayOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RigSnapshotValue &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.controlName == this.controlName &&
          other.controlPedalName == this.controlPedalName &&
          other.controlType == this.controlType &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.options == this.options &&
          other.displayOrder == this.displayOrder);
}

class RigSnapshotValuesCompanion extends UpdateCompanion<RigSnapshotValue> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> controlName;
  final Value<String?> controlPedalName;
  final Value<ControlType> controlType;
  final Value<double> value;
  final Value<String?> unit;
  final Value<String?> options;
  final Value<int> displayOrder;
  const RigSnapshotValuesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.controlName = const Value.absent(),
    this.controlPedalName = const Value.absent(),
    this.controlType = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.options = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  RigSnapshotValuesCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String controlName,
    this.controlPedalName = const Value.absent(),
    required ControlType controlType,
    required double value,
    this.unit = const Value.absent(),
    this.options = const Value.absent(),
    required int displayOrder,
  }) : entryId = Value(entryId),
       controlName = Value(controlName),
       controlType = Value(controlType),
       value = Value(value),
       displayOrder = Value(displayOrder);
  static Insertable<RigSnapshotValue> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? controlName,
    Expression<String>? controlPedalName,
    Expression<String>? controlType,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? options,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (controlName != null) 'control_name': controlName,
      if (controlPedalName != null) 'control_pedal_name': controlPedalName,
      if (controlType != null) 'control_type': controlType,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (options != null) 'options': options,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  RigSnapshotValuesCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? controlName,
    Value<String?>? controlPedalName,
    Value<ControlType>? controlType,
    Value<double>? value,
    Value<String?>? unit,
    Value<String?>? options,
    Value<int>? displayOrder,
  }) {
    return RigSnapshotValuesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      controlName: controlName ?? this.controlName,
      controlPedalName: controlPedalName ?? this.controlPedalName,
      controlType: controlType ?? this.controlType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      options: options ?? this.options,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (controlName.present) {
      map['control_name'] = Variable<String>(controlName.value);
    }
    if (controlPedalName.present) {
      map['control_pedal_name'] = Variable<String>(controlPedalName.value);
    }
    if (controlType.present) {
      map['control_type'] = Variable<String>(
        $RigSnapshotValuesTable.$convertercontrolType.toSql(controlType.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RigSnapshotValuesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('controlName: $controlName, ')
          ..write('controlPedalName: $controlPedalName, ')
          ..write('controlType: $controlType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('options: $options, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PedalsTable pedals = $PedalsTable(this);
  late final $PedalControlsTable pedalControls = $PedalControlsTable(this);
  late final $ConfigurationsTable configurations = $ConfigurationsTable(this);
  late final $ConfigurationValuesTable configurationValues =
      $ConfigurationValuesTable(this);
  late final $PatchesTable patches = $PatchesTable(this);
  late final $ScenesTable scenes = $ScenesTable(this);
  late final $ScenePedalsTable scenePedals = $ScenePedalsTable(this);
  late final $SceneValuesTable sceneValues = $SceneValuesTable(this);
  late final $ChangeLogsTable changeLogs = $ChangeLogsTable(this);
  late final $PedalReplacementsTable pedalReplacements =
      $PedalReplacementsTable(this);
  late final $PedalboardsTable pedalboards = $PedalboardsTable(this);
  late final $SignalBlocksTable signalBlocks = $SignalBlocksTable(this);
  late final $SignalConnectionsTable signalConnections =
      $SignalConnectionsTable(this);
  late final $SignalEndpointsTable signalEndpoints = $SignalEndpointsTable(
    this,
  );
  late final $RigSnapshotsTable rigSnapshots = $RigSnapshotsTable(this);
  late final $RigSnapshotEntriesTable rigSnapshotEntries =
      $RigSnapshotEntriesTable(this);
  late final $RigSnapshotValuesTable rigSnapshotValues =
      $RigSnapshotValuesTable(this);
  late final Index idxPedalsStatus = Index(
    'idx_pedals_status',
    'CREATE INDEX idx_pedals_status ON pedals (status)',
  );
  late final Index idxPedalsName = Index(
    'idx_pedals_name',
    'CREATE INDEX idx_pedals_name ON pedals (name)',
  );
  late final Index idxPedalsHost = Index(
    'idx_pedals_host',
    'CREATE INDEX idx_pedals_host ON pedals (host_pedal_id)',
  );
  late final Index idxPedalControlsPedalOrder = Index(
    'idx_pedal_controls_pedal_order',
    'CREATE INDEX idx_pedal_controls_pedal_order ON pedal_controls (pedal_id, display_order)',
  );
  late final Index idxConfigurationsPedal = Index(
    'idx_configurations_pedal',
    'CREATE INDEX idx_configurations_pedal ON configurations (pedal_id)',
  );
  late final Index idxPatchesPedal = Index(
    'idx_patches_pedal',
    'CREATE INDEX idx_patches_pedal ON patches (pedal_id)',
  );
  late final Index idxScenesPatch = Index(
    'idx_scenes_patch',
    'CREATE INDEX idx_scenes_patch ON scenes (patch_id)',
  );
  late final Index idxChangeLogsPedalTime = Index(
    'idx_change_logs_pedal_time',
    'CREATE INDEX idx_change_logs_pedal_time ON change_logs (pedal_id, created_at)',
  );
  late final Index idxChangeLogsConfiguration = Index(
    'idx_change_logs_configuration',
    'CREATE INDEX idx_change_logs_configuration ON change_logs (configuration_id)',
  );
  late final Index idxPedalReplacementsOld = Index(
    'idx_pedal_replacements_old',
    'CREATE INDEX idx_pedal_replacements_old ON pedal_replacements (old_pedal_id)',
  );
  late final Index idxPedalReplacementsNew = Index(
    'idx_pedal_replacements_new',
    'CREATE INDEX idx_pedal_replacements_new ON pedal_replacements (new_pedal_id)',
  );
  late final Index idxSignalBlocksBoardPosition = Index(
    'idx_signal_blocks_board_position',
    'CREATE INDEX idx_signal_blocks_board_position ON signal_blocks (pedalboard_id, position)',
  );
  late final Index idxSignalConnectionsBoard = Index(
    'idx_signal_connections_board',
    'CREATE INDEX idx_signal_connections_board ON signal_connections (pedalboard_id)',
  );
  late final Index idxRigSnapshotsBoardCaptured = Index(
    'idx_rig_snapshots_board_captured',
    'CREATE INDEX idx_rig_snapshots_board_captured ON rig_snapshots (pedalboard_id, captured_at)',
  );
  late final Index idxRigSnapshotEntriesSnapshotPosition = Index(
    'idx_rig_snapshot_entries_snapshot_position',
    'CREATE INDEX idx_rig_snapshot_entries_snapshot_position ON rig_snapshot_entries (snapshot_id, position)',
  );
  late final PedalDao pedalDao = PedalDao(this as AppDatabase);
  late final PedalControlDao pedalControlDao = PedalControlDao(
    this as AppDatabase,
  );
  late final ConfigurationDao configurationDao = ConfigurationDao(
    this as AppDatabase,
  );
  late final PatchDao patchDao = PatchDao(this as AppDatabase);
  late final SceneDao sceneDao = SceneDao(this as AppDatabase);
  late final ChangeLogDao changeLogDao = ChangeLogDao(this as AppDatabase);
  late final PedalReplacementDao pedalReplacementDao = PedalReplacementDao(
    this as AppDatabase,
  );
  late final PedalboardDao pedalboardDao = PedalboardDao(this as AppDatabase);
  late final SignalChainDao signalChainDao = SignalChainDao(
    this as AppDatabase,
  );
  late final SignalEndpointDao signalEndpointDao = SignalEndpointDao(
    this as AppDatabase,
  );
  late final RigSnapshotDao rigSnapshotDao = RigSnapshotDao(
    this as AppDatabase,
  );
  late final BackupDao backupDao = BackupDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pedals,
    pedalControls,
    configurations,
    configurationValues,
    patches,
    scenes,
    scenePedals,
    sceneValues,
    changeLogs,
    pedalReplacements,
    pedalboards,
    signalBlocks,
    signalConnections,
    signalEndpoints,
    rigSnapshots,
    rigSnapshotEntries,
    rigSnapshotValues,
    idxPedalsStatus,
    idxPedalsName,
    idxPedalsHost,
    idxPedalControlsPedalOrder,
    idxConfigurationsPedal,
    idxPatchesPedal,
    idxScenesPatch,
    idxChangeLogsPedalTime,
    idxChangeLogsConfiguration,
    idxPedalReplacementsOld,
    idxPedalReplacementsNew,
    idxSignalBlocksBoardPosition,
    idxSignalConnectionsBoard,
    idxRigSnapshotsBoardCaptured,
    idxRigSnapshotEntriesSnapshotPosition,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'configurations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('configuration_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedal_controls',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('configuration_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scenes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scenes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scene_pedals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scenes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scene_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedal_controls',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scene_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'configurations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('change_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedal_controls',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('change_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedalboards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_blocks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedalboards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_connections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_connections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_connections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_endpoints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_endpoints', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rig_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rig_snapshot_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rig_snapshot_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rig_snapshot_values', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PedalsTableCreateCompanionBuilder =
    PedalsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> brand,
      required PedalType type,
      required PedalCategory category,
      Value<PedalStatus> status,
      Value<int?> hostPedalId,
      Value<MultiEffectsMode?> multiEffectsMode,
      Value<String?> photoPath,
      Value<DateTime?> purchaseDate,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PedalsTableUpdateCompanionBuilder =
    PedalsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> brand,
      Value<PedalType> type,
      Value<PedalCategory> category,
      Value<PedalStatus> status,
      Value<int?> hostPedalId,
      Value<MultiEffectsMode?> multiEffectsMode,
      Value<String?> photoPath,
      Value<DateTime?> purchaseDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PedalsTableReferences
    extends BaseReferences<_$AppDatabase, $PedalsTable, Pedal> {
  $$PedalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedalsTable _hostPedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('pedals__host_pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager? get hostPedalId {
    final $_column = $_itemColumn<int>('host_pedal_id');
    if ($_column == null) return null;
    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hostPedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PedalControlsTable, List<PedalControl>>
  _pedalControlsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pedalControls,
    aliasName: 'pedals__id__pedal_controls__pedal_id',
  );

  $$PedalControlsTableProcessedTableManager get pedalControlsRefs {
    final manager = $$PedalControlsTableTableManager(
      $_db,
      $_db.pedalControls,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pedalControlsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConfigurationsTable, List<Configuration>>
  _configurationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.configurations,
    aliasName: 'pedals__id__configurations__pedal_id',
  );

  $$ConfigurationsTableProcessedTableManager get configurationsRefs {
    final manager = $$ConfigurationsTableTableManager(
      $_db,
      $_db.configurations,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_configurationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PatchesTable, List<Patch>> _patchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.patches,
    aliasName: 'pedals__id__patches__pedal_id',
  );

  $$PatchesTableProcessedTableManager get patchesRefs {
    final manager = $$PatchesTableTableManager(
      $_db,
      $_db.patches,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_patchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScenePedalsTable, List<ScenePedal>>
  _scenePedalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scenePedals,
    aliasName: 'pedals__id__scene_pedals__pedal_id',
  );

  $$ScenePedalsTableProcessedTableManager get scenePedalsRefs {
    final manager = $$ScenePedalsTableTableManager(
      $_db,
      $_db.scenePedals,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenePedalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChangeLogsTable, List<ChangeLog>>
  _changeLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.changeLogs,
    aliasName: 'pedals__id__change_logs__pedal_id',
  );

  $$ChangeLogsTableProcessedTableManager get changeLogsRefs {
    final manager = $$ChangeLogsTableTableManager(
      $_db,
      $_db.changeLogs,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_changeLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PedalReplacementsTable, List<PedalReplacement>>
  _replacementsWhereOutgoingTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pedalReplacements,
        aliasName: 'pedals__id__pedal_replacements__old_pedal_id',
      );

  $$PedalReplacementsTableProcessedTableManager get replacementsWhereOutgoing {
    final manager = $$PedalReplacementsTableTableManager(
      $_db,
      $_db.pedalReplacements,
    ).filter((f) => f.oldPedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _replacementsWhereOutgoingTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PedalReplacementsTable, List<PedalReplacement>>
  _replacementsWhereIncomingTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pedalReplacements,
        aliasName: 'pedals__id__pedal_replacements__new_pedal_id',
      );

  $$PedalReplacementsTableProcessedTableManager get replacementsWhereIncoming {
    final manager = $$PedalReplacementsTableTableManager(
      $_db,
      $_db.pedalReplacements,
    ).filter((f) => f.newPedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _replacementsWhereIncomingTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalBlocksTable, List<SignalBlock>>
  _signalBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalBlocks,
    aliasName: 'pedals__id__signal_blocks__pedal_id',
  );

  $$SignalBlocksTableProcessedTableManager get signalBlocksRefs {
    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RigSnapshotEntriesTable, List<RigSnapshotEntry>>
  _rigSnapshotEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rigSnapshotEntries,
        aliasName: 'pedals__id__rig_snapshot_entries__pedal_id',
      );

  $$RigSnapshotEntriesTableProcessedTableManager get rigSnapshotEntriesRefs {
    final manager = $$RigSnapshotEntriesTableTableManager(
      $_db,
      $_db.rigSnapshotEntries,
    ).filter((f) => f.pedalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rigSnapshotEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PedalsTableFilterComposer
    extends Composer<_$AppDatabase, $PedalsTable> {
  $$PedalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PedalType, PedalType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PedalCategory, PedalCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PedalStatus, PedalStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MultiEffectsMode?, MultiEffectsMode, String>
  get multiEffectsMode => $composableBuilder(
    column: $table.multiEffectsMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get hostPedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pedalControlsRefs(
    Expression<bool> Function($$PedalControlsTableFilterComposer f) f,
  ) {
    final $$PedalControlsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableFilterComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> configurationsRefs(
    Expression<bool> Function($$ConfigurationsTableFilterComposer f) f,
  ) {
    final $$ConfigurationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableFilterComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> patchesRefs(
    Expression<bool> Function($$PatchesTableFilterComposer f) f,
  ) {
    final $$PatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patches,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatchesTableFilterComposer(
            $db: $db,
            $table: $db.patches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scenePedalsRefs(
    Expression<bool> Function($$ScenePedalsTableFilterComposer f) f,
  ) {
    final $$ScenePedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenePedals,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenePedalsTableFilterComposer(
            $db: $db,
            $table: $db.scenePedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> changeLogsRefs(
    Expression<bool> Function($$ChangeLogsTableFilterComposer f) f,
  ) {
    final $$ChangeLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableFilterComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> replacementsWhereOutgoing(
    Expression<bool> Function($$PedalReplacementsTableFilterComposer f) f,
  ) {
    final $$PedalReplacementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pedalReplacements,
      getReferencedColumn: (t) => t.oldPedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalReplacementsTableFilterComposer(
            $db: $db,
            $table: $db.pedalReplacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> replacementsWhereIncoming(
    Expression<bool> Function($$PedalReplacementsTableFilterComposer f) f,
  ) {
    final $$PedalReplacementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pedalReplacements,
      getReferencedColumn: (t) => t.newPedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalReplacementsTableFilterComposer(
            $db: $db,
            $table: $db.pedalReplacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> signalBlocksRefs(
    Expression<bool> Function($$SignalBlocksTableFilterComposer f) f,
  ) {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rigSnapshotEntriesRefs(
    Expression<bool> Function($$RigSnapshotEntriesTableFilterComposer f) f,
  ) {
    final $$RigSnapshotEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rigSnapshotEntries,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotEntriesTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshotEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedalsTableOrderingComposer
    extends Composer<_$AppDatabase, $PedalsTable> {
  $$PedalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get multiEffectsMode => $composableBuilder(
    column: $table.multiEffectsMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get hostPedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PedalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedalsTable> {
  $$PedalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PedalType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PedalCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PedalStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MultiEffectsMode?, String>
  get multiEffectsMode => $composableBuilder(
    column: $table.multiEffectsMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PedalsTableAnnotationComposer get hostPedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hostPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pedalControlsRefs<T extends Object>(
    Expression<T> Function($$PedalControlsTableAnnotationComposer a) f,
  ) {
    final $$PedalControlsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> configurationsRefs<T extends Object>(
    Expression<T> Function($$ConfigurationsTableAnnotationComposer a) f,
  ) {
    final $$ConfigurationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableAnnotationComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> patchesRefs<T extends Object>(
    Expression<T> Function($$PatchesTableAnnotationComposer a) f,
  ) {
    final $$PatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patches,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.patches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scenePedalsRefs<T extends Object>(
    Expression<T> Function($$ScenePedalsTableAnnotationComposer a) f,
  ) {
    final $$ScenePedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenePedals,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenePedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.scenePedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> changeLogsRefs<T extends Object>(
    Expression<T> Function($$ChangeLogsTableAnnotationComposer a) f,
  ) {
    final $$ChangeLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> replacementsWhereOutgoing<T extends Object>(
    Expression<T> Function($$PedalReplacementsTableAnnotationComposer a) f,
  ) {
    final $$PedalReplacementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pedalReplacements,
          getReferencedColumn: (t) => t.oldPedalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PedalReplacementsTableAnnotationComposer(
                $db: $db,
                $table: $db.pedalReplacements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> replacementsWhereIncoming<T extends Object>(
    Expression<T> Function($$PedalReplacementsTableAnnotationComposer a) f,
  ) {
    final $$PedalReplacementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pedalReplacements,
          getReferencedColumn: (t) => t.newPedalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PedalReplacementsTableAnnotationComposer(
                $db: $db,
                $table: $db.pedalReplacements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> signalBlocksRefs<T extends Object>(
    Expression<T> Function($$SignalBlocksTableAnnotationComposer a) f,
  ) {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.pedalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rigSnapshotEntriesRefs<T extends Object>(
    Expression<T> Function($$RigSnapshotEntriesTableAnnotationComposer a) f,
  ) {
    final $$RigSnapshotEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rigSnapshotEntries,
          getReferencedColumn: (t) => t.pedalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RigSnapshotEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.rigSnapshotEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PedalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedalsTable,
          Pedal,
          $$PedalsTableFilterComposer,
          $$PedalsTableOrderingComposer,
          $$PedalsTableAnnotationComposer,
          $$PedalsTableCreateCompanionBuilder,
          $$PedalsTableUpdateCompanionBuilder,
          (Pedal, $$PedalsTableReferences),
          Pedal,
          PrefetchHooks Function({
            bool hostPedalId,
            bool pedalControlsRefs,
            bool configurationsRefs,
            bool patchesRefs,
            bool scenePedalsRefs,
            bool changeLogsRefs,
            bool replacementsWhereOutgoing,
            bool replacementsWhereIncoming,
            bool signalBlocksRefs,
            bool rigSnapshotEntriesRefs,
          })
        > {
  $$PedalsTableTableManager(_$AppDatabase db, $PedalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<PedalType> type = const Value.absent(),
                Value<PedalCategory> category = const Value.absent(),
                Value<PedalStatus> status = const Value.absent(),
                Value<int?> hostPedalId = const Value.absent(),
                Value<MultiEffectsMode?> multiEffectsMode =
                    const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PedalsCompanion(
                id: id,
                name: name,
                brand: brand,
                type: type,
                category: category,
                status: status,
                hostPedalId: hostPedalId,
                multiEffectsMode: multiEffectsMode,
                photoPath: photoPath,
                purchaseDate: purchaseDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required PedalType type,
                required PedalCategory category,
                Value<PedalStatus> status = const Value.absent(),
                Value<int?> hostPedalId = const Value.absent(),
                Value<MultiEffectsMode?> multiEffectsMode =
                    const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PedalsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                type: type,
                category: category,
                status: status,
                hostPedalId: hostPedalId,
                multiEffectsMode: multiEffectsMode,
                photoPath: photoPath,
                purchaseDate: purchaseDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PedalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                hostPedalId = false,
                pedalControlsRefs = false,
                configurationsRefs = false,
                patchesRefs = false,
                scenePedalsRefs = false,
                changeLogsRefs = false,
                replacementsWhereOutgoing = false,
                replacementsWhereIncoming = false,
                signalBlocksRefs = false,
                rigSnapshotEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pedalControlsRefs) db.pedalControls,
                    if (configurationsRefs) db.configurations,
                    if (patchesRefs) db.patches,
                    if (scenePedalsRefs) db.scenePedals,
                    if (changeLogsRefs) db.changeLogs,
                    if (replacementsWhereOutgoing) db.pedalReplacements,
                    if (replacementsWhereIncoming) db.pedalReplacements,
                    if (signalBlocksRefs) db.signalBlocks,
                    if (rigSnapshotEntriesRefs) db.rigSnapshotEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (hostPedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.hostPedalId,
                                    referencedTable: $$PedalsTableReferences
                                        ._hostPedalIdTable(db),
                                    referencedColumn: $$PedalsTableReferences
                                        ._hostPedalIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pedalControlsRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          PedalControl
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._pedalControlsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).pedalControlsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (configurationsRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          Configuration
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._configurationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).configurationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (patchesRefs)
                        await $_getPrefetchedData<Pedal, $PedalsTable, Patch>(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._patchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).patchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scenePedalsRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          ScenePedal
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._scenePedalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).scenePedalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (changeLogsRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          ChangeLog
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._changeLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).changeLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (replacementsWhereOutgoing)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          PedalReplacement
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._replacementsWhereOutgoingTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).replacementsWhereOutgoing,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.oldPedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (replacementsWhereIncoming)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          PedalReplacement
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._replacementsWhereIncomingTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).replacementsWhereIncoming,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.newPedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (signalBlocksRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          SignalBlock
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._signalBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).signalBlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rigSnapshotEntriesRefs)
                        await $_getPrefetchedData<
                          Pedal,
                          $PedalsTable,
                          RigSnapshotEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PedalsTableReferences
                              ._rigSnapshotEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalsTableReferences(
                                db,
                                table,
                                p0,
                              ).rigSnapshotEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PedalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedalsTable,
      Pedal,
      $$PedalsTableFilterComposer,
      $$PedalsTableOrderingComposer,
      $$PedalsTableAnnotationComposer,
      $$PedalsTableCreateCompanionBuilder,
      $$PedalsTableUpdateCompanionBuilder,
      (Pedal, $$PedalsTableReferences),
      Pedal,
      PrefetchHooks Function({
        bool hostPedalId,
        bool pedalControlsRefs,
        bool configurationsRefs,
        bool patchesRefs,
        bool scenePedalsRefs,
        bool changeLogsRefs,
        bool replacementsWhereOutgoing,
        bool replacementsWhereIncoming,
        bool signalBlocksRefs,
        bool rigSnapshotEntriesRefs,
      })
    >;
typedef $$PedalControlsTableCreateCompanionBuilder =
    PedalControlsCompanion Function({
      Value<int> id,
      required int pedalId,
      required String name,
      required ControlType controlType,
      required double minValue,
      required double maxValue,
      Value<double?> step,
      Value<double?> defaultValue,
      Value<String?> unit,
      Value<String?> options,
      required int displayOrder,
    });
typedef $$PedalControlsTableUpdateCompanionBuilder =
    PedalControlsCompanion Function({
      Value<int> id,
      Value<int> pedalId,
      Value<String> name,
      Value<ControlType> controlType,
      Value<double> minValue,
      Value<double> maxValue,
      Value<double?> step,
      Value<double?> defaultValue,
      Value<String?> unit,
      Value<String?> options,
      Value<int> displayOrder,
    });

final class $$PedalControlsTableReferences
    extends BaseReferences<_$AppDatabase, $PedalControlsTable, PedalControl> {
  $$PedalControlsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('pedal_controls__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ConfigurationValuesTable,
    List<ConfigurationValue>
  >
  _configurationValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.configurationValues,
        aliasName: 'pedal_controls__id__configuration_values__control_id',
      );

  $$ConfigurationValuesTableProcessedTableManager get configurationValuesRefs {
    final manager = $$ConfigurationValuesTableTableManager(
      $_db,
      $_db.configurationValues,
    ).filter((f) => f.controlId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _configurationValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SceneValuesTable, List<SceneValue>>
  _sceneValuesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sceneValues,
    aliasName: 'pedal_controls__id__scene_values__control_id',
  );

  $$SceneValuesTableProcessedTableManager get sceneValuesRefs {
    final manager = $$SceneValuesTableTableManager(
      $_db,
      $_db.sceneValues,
    ).filter((f) => f.controlId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sceneValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChangeLogsTable, List<ChangeLog>>
  _changeLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.changeLogs,
    aliasName: 'pedal_controls__id__change_logs__control_id',
  );

  $$ChangeLogsTableProcessedTableManager get changeLogsRefs {
    final manager = $$ChangeLogsTableTableManager(
      $_db,
      $_db.changeLogs,
    ).filter((f) => f.controlId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_changeLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PedalControlsTableFilterComposer
    extends Composer<_$AppDatabase, $PedalControlsTable> {
  $$PedalControlsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ControlType, ControlType, String>
  get controlType => $composableBuilder(
    column: $table.controlType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultValue => $composableBuilder(
    column: $table.defaultValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> configurationValuesRefs(
    Expression<bool> Function($$ConfigurationValuesTableFilterComposer f) f,
  ) {
    final $$ConfigurationValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configurationValues,
      getReferencedColumn: (t) => t.controlId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationValuesTableFilterComposer(
            $db: $db,
            $table: $db.configurationValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sceneValuesRefs(
    Expression<bool> Function($$SceneValuesTableFilterComposer f) f,
  ) {
    final $$SceneValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sceneValues,
      getReferencedColumn: (t) => t.controlId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SceneValuesTableFilterComposer(
            $db: $db,
            $table: $db.sceneValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> changeLogsRefs(
    Expression<bool> Function($$ChangeLogsTableFilterComposer f) f,
  ) {
    final $$ChangeLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.controlId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableFilterComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedalControlsTableOrderingComposer
    extends Composer<_$AppDatabase, $PedalControlsTable> {
  $$PedalControlsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlType => $composableBuilder(
    column: $table.controlType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultValue => $composableBuilder(
    column: $table.defaultValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PedalControlsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedalControlsTable> {
  $$PedalControlsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ControlType, String> get controlType =>
      $composableBuilder(
        column: $table.controlType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<double> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<double> get defaultValue => $composableBuilder(
    column: $table.defaultValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> configurationValuesRefs<T extends Object>(
    Expression<T> Function($$ConfigurationValuesTableAnnotationComposer a) f,
  ) {
    final $$ConfigurationValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.configurationValues,
          getReferencedColumn: (t) => t.controlId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConfigurationValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.configurationValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sceneValuesRefs<T extends Object>(
    Expression<T> Function($$SceneValuesTableAnnotationComposer a) f,
  ) {
    final $$SceneValuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sceneValues,
      getReferencedColumn: (t) => t.controlId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SceneValuesTableAnnotationComposer(
            $db: $db,
            $table: $db.sceneValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> changeLogsRefs<T extends Object>(
    Expression<T> Function($$ChangeLogsTableAnnotationComposer a) f,
  ) {
    final $$ChangeLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.controlId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedalControlsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedalControlsTable,
          PedalControl,
          $$PedalControlsTableFilterComposer,
          $$PedalControlsTableOrderingComposer,
          $$PedalControlsTableAnnotationComposer,
          $$PedalControlsTableCreateCompanionBuilder,
          $$PedalControlsTableUpdateCompanionBuilder,
          (PedalControl, $$PedalControlsTableReferences),
          PedalControl,
          PrefetchHooks Function({
            bool pedalId,
            bool configurationValuesRefs,
            bool sceneValuesRefs,
            bool changeLogsRefs,
          })
        > {
  $$PedalControlsTableTableManager(_$AppDatabase db, $PedalControlsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedalControlsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedalControlsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedalControlsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ControlType> controlType = const Value.absent(),
                Value<double> minValue = const Value.absent(),
                Value<double> maxValue = const Value.absent(),
                Value<double?> step = const Value.absent(),
                Value<double?> defaultValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> options = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => PedalControlsCompanion(
                id: id,
                pedalId: pedalId,
                name: name,
                controlType: controlType,
                minValue: minValue,
                maxValue: maxValue,
                step: step,
                defaultValue: defaultValue,
                unit: unit,
                options: options,
                displayOrder: displayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalId,
                required String name,
                required ControlType controlType,
                required double minValue,
                required double maxValue,
                Value<double?> step = const Value.absent(),
                Value<double?> defaultValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> options = const Value.absent(),
                required int displayOrder,
              }) => PedalControlsCompanion.insert(
                id: id,
                pedalId: pedalId,
                name: name,
                controlType: controlType,
                minValue: minValue,
                maxValue: maxValue,
                step: step,
                defaultValue: defaultValue,
                unit: unit,
                options: options,
                displayOrder: displayOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PedalControlsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pedalId = false,
                configurationValuesRefs = false,
                sceneValuesRefs = false,
                changeLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (configurationValuesRefs) db.configurationValues,
                    if (sceneValuesRefs) db.sceneValues,
                    if (changeLogsRefs) db.changeLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalId,
                                    referencedTable:
                                        $$PedalControlsTableReferences
                                            ._pedalIdTable(db),
                                    referencedColumn:
                                        $$PedalControlsTableReferences
                                            ._pedalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (configurationValuesRefs)
                        await $_getPrefetchedData<
                          PedalControl,
                          $PedalControlsTable,
                          ConfigurationValue
                        >(
                          currentTable: table,
                          referencedTable: $$PedalControlsTableReferences
                              ._configurationValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalControlsTableReferences(
                                db,
                                table,
                                p0,
                              ).configurationValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.controlId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sceneValuesRefs)
                        await $_getPrefetchedData<
                          PedalControl,
                          $PedalControlsTable,
                          SceneValue
                        >(
                          currentTable: table,
                          referencedTable: $$PedalControlsTableReferences
                              ._sceneValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalControlsTableReferences(
                                db,
                                table,
                                p0,
                              ).sceneValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.controlId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (changeLogsRefs)
                        await $_getPrefetchedData<
                          PedalControl,
                          $PedalControlsTable,
                          ChangeLog
                        >(
                          currentTable: table,
                          referencedTable: $$PedalControlsTableReferences
                              ._changeLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalControlsTableReferences(
                                db,
                                table,
                                p0,
                              ).changeLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.controlId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PedalControlsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedalControlsTable,
      PedalControl,
      $$PedalControlsTableFilterComposer,
      $$PedalControlsTableOrderingComposer,
      $$PedalControlsTableAnnotationComposer,
      $$PedalControlsTableCreateCompanionBuilder,
      $$PedalControlsTableUpdateCompanionBuilder,
      (PedalControl, $$PedalControlsTableReferences),
      PedalControl,
      PrefetchHooks Function({
        bool pedalId,
        bool configurationValuesRefs,
        bool sceneValuesRefs,
        bool changeLogsRefs,
      })
    >;
typedef $$ConfigurationsTableCreateCompanionBuilder =
    ConfigurationsCompanion Function({
      Value<int> id,
      required int pedalId,
      required String name,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ConfigurationsTableUpdateCompanionBuilder =
    ConfigurationsCompanion Function({
      Value<int> id,
      Value<int> pedalId,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ConfigurationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConfigurationsTable, Configuration> {
  $$ConfigurationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('configurations__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ConfigurationValuesTable,
    List<ConfigurationValue>
  >
  _configurationValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.configurationValues,
        aliasName: 'configurations__id__configuration_values__configuration_id',
      );

  $$ConfigurationValuesTableProcessedTableManager get configurationValuesRefs {
    final manager = $$ConfigurationValuesTableTableManager(
      $_db,
      $_db.configurationValues,
    ).filter((f) => f.configurationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _configurationValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChangeLogsTable, List<ChangeLog>>
  _changeLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.changeLogs,
    aliasName: 'configurations__id__change_logs__configuration_id',
  );

  $$ChangeLogsTableProcessedTableManager get changeLogsRefs {
    final manager = $$ChangeLogsTableTableManager(
      $_db,
      $_db.changeLogs,
    ).filter((f) => f.configurationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_changeLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigurationsTable> {
  $$ConfigurationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> configurationValuesRefs(
    Expression<bool> Function($$ConfigurationValuesTableFilterComposer f) f,
  ) {
    final $$ConfigurationValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configurationValues,
      getReferencedColumn: (t) => t.configurationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationValuesTableFilterComposer(
            $db: $db,
            $table: $db.configurationValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> changeLogsRefs(
    Expression<bool> Function($$ChangeLogsTableFilterComposer f) f,
  ) {
    final $$ChangeLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.configurationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableFilterComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigurationsTable> {
  $$ConfigurationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigurationsTable> {
  $$ConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> configurationValuesRefs<T extends Object>(
    Expression<T> Function($$ConfigurationValuesTableAnnotationComposer a) f,
  ) {
    final $$ConfigurationValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.configurationValues,
          getReferencedColumn: (t) => t.configurationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConfigurationValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.configurationValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> changeLogsRefs<T extends Object>(
    Expression<T> Function($$ChangeLogsTableAnnotationComposer a) f,
  ) {
    final $$ChangeLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.changeLogs,
      getReferencedColumn: (t) => t.configurationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChangeLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.changeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigurationsTable,
          Configuration,
          $$ConfigurationsTableFilterComposer,
          $$ConfigurationsTableOrderingComposer,
          $$ConfigurationsTableAnnotationComposer,
          $$ConfigurationsTableCreateCompanionBuilder,
          $$ConfigurationsTableUpdateCompanionBuilder,
          (Configuration, $$ConfigurationsTableReferences),
          Configuration,
          PrefetchHooks Function({
            bool pedalId,
            bool configurationValuesRefs,
            bool changeLogsRefs,
          })
        > {
  $$ConfigurationsTableTableManager(
    _$AppDatabase db,
    $ConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigurationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigurationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigurationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ConfigurationsCompanion(
                id: id,
                pedalId: pedalId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ConfigurationsCompanion.insert(
                id: id,
                pedalId: pedalId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConfigurationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pedalId = false,
                configurationValuesRefs = false,
                changeLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (configurationValuesRefs) db.configurationValues,
                    if (changeLogsRefs) db.changeLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalId,
                                    referencedTable:
                                        $$ConfigurationsTableReferences
                                            ._pedalIdTable(db),
                                    referencedColumn:
                                        $$ConfigurationsTableReferences
                                            ._pedalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (configurationValuesRefs)
                        await $_getPrefetchedData<
                          Configuration,
                          $ConfigurationsTable,
                          ConfigurationValue
                        >(
                          currentTable: table,
                          referencedTable: $$ConfigurationsTableReferences
                              ._configurationValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConfigurationsTableReferences(
                                db,
                                table,
                                p0,
                              ).configurationValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.configurationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (changeLogsRefs)
                        await $_getPrefetchedData<
                          Configuration,
                          $ConfigurationsTable,
                          ChangeLog
                        >(
                          currentTable: table,
                          referencedTable: $$ConfigurationsTableReferences
                              ._changeLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConfigurationsTableReferences(
                                db,
                                table,
                                p0,
                              ).changeLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.configurationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigurationsTable,
      Configuration,
      $$ConfigurationsTableFilterComposer,
      $$ConfigurationsTableOrderingComposer,
      $$ConfigurationsTableAnnotationComposer,
      $$ConfigurationsTableCreateCompanionBuilder,
      $$ConfigurationsTableUpdateCompanionBuilder,
      (Configuration, $$ConfigurationsTableReferences),
      Configuration,
      PrefetchHooks Function({
        bool pedalId,
        bool configurationValuesRefs,
        bool changeLogsRefs,
      })
    >;
typedef $$ConfigurationValuesTableCreateCompanionBuilder =
    ConfigurationValuesCompanion Function({
      Value<int> id,
      required int configurationId,
      required int controlId,
      required double value,
    });
typedef $$ConfigurationValuesTableUpdateCompanionBuilder =
    ConfigurationValuesCompanion Function({
      Value<int> id,
      Value<int> configurationId,
      Value<int> controlId,
      Value<double> value,
    });

final class $$ConfigurationValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConfigurationValuesTable,
          ConfigurationValue
        > {
  $$ConfigurationValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConfigurationsTable _configurationIdTable(_$AppDatabase db) =>
      db.configurations.createAlias(
        'configuration_values__configuration_id__configurations__id',
      );

  $$ConfigurationsTableProcessedTableManager get configurationId {
    final $_column = $_itemColumn<int>('configuration_id')!;

    final manager = $$ConfigurationsTableTableManager(
      $_db,
      $_db.configurations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_configurationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalControlsTable _controlIdTable(_$AppDatabase db) => db
      .pedalControls
      .createAlias('configuration_values__control_id__pedal_controls__id');

  $$PedalControlsTableProcessedTableManager get controlId {
    final $_column = $_itemColumn<int>('control_id')!;

    final manager = $$PedalControlsTableTableManager(
      $_db,
      $_db.pedalControls,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_controlIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConfigurationValuesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigurationValuesTable> {
  $$ConfigurationValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$ConfigurationsTableFilterComposer get configurationId {
    final $$ConfigurationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableFilterComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableFilterComposer get controlId {
    final $$PedalControlsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableFilterComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfigurationValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigurationValuesTable> {
  $$ConfigurationValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConfigurationsTableOrderingComposer get configurationId {
    final $$ConfigurationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableOrderingComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableOrderingComposer get controlId {
    final $$PedalControlsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfigurationValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigurationValuesTable> {
  $$ConfigurationValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$ConfigurationsTableAnnotationComposer get configurationId {
    final $$ConfigurationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableAnnotationComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableAnnotationComposer get controlId {
    final $$PedalControlsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfigurationValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigurationValuesTable,
          ConfigurationValue,
          $$ConfigurationValuesTableFilterComposer,
          $$ConfigurationValuesTableOrderingComposer,
          $$ConfigurationValuesTableAnnotationComposer,
          $$ConfigurationValuesTableCreateCompanionBuilder,
          $$ConfigurationValuesTableUpdateCompanionBuilder,
          (ConfigurationValue, $$ConfigurationValuesTableReferences),
          ConfigurationValue,
          PrefetchHooks Function({bool configurationId, bool controlId})
        > {
  $$ConfigurationValuesTableTableManager(
    _$AppDatabase db,
    $ConfigurationValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigurationValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigurationValuesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConfigurationValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> configurationId = const Value.absent(),
                Value<int> controlId = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => ConfigurationValuesCompanion(
                id: id,
                configurationId: configurationId,
                controlId: controlId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int configurationId,
                required int controlId,
                required double value,
              }) => ConfigurationValuesCompanion.insert(
                id: id,
                configurationId: configurationId,
                controlId: controlId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConfigurationValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({configurationId = false, controlId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (configurationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.configurationId,
                                    referencedTable:
                                        $$ConfigurationValuesTableReferences
                                            ._configurationIdTable(db),
                                    referencedColumn:
                                        $$ConfigurationValuesTableReferences
                                            ._configurationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (controlId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.controlId,
                                    referencedTable:
                                        $$ConfigurationValuesTableReferences
                                            ._controlIdTable(db),
                                    referencedColumn:
                                        $$ConfigurationValuesTableReferences
                                            ._controlIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ConfigurationValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigurationValuesTable,
      ConfigurationValue,
      $$ConfigurationValuesTableFilterComposer,
      $$ConfigurationValuesTableOrderingComposer,
      $$ConfigurationValuesTableAnnotationComposer,
      $$ConfigurationValuesTableCreateCompanionBuilder,
      $$ConfigurationValuesTableUpdateCompanionBuilder,
      (ConfigurationValue, $$ConfigurationValuesTableReferences),
      ConfigurationValue,
      PrefetchHooks Function({bool configurationId, bool controlId})
    >;
typedef $$PatchesTableCreateCompanionBuilder =
    PatchesCompanion Function({
      Value<int> id,
      required int pedalId,
      required String name,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PatchesTableUpdateCompanionBuilder =
    PatchesCompanion Function({
      Value<int> id,
      Value<int> pedalId,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PatchesTableReferences
    extends BaseReferences<_$AppDatabase, $PatchesTable, Patch> {
  $$PatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('patches__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScenesTable, List<Scene>> _scenesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scenes,
    aliasName: 'patches__id__scenes__patch_id',
  );

  $$ScenesTableProcessedTableManager get scenesRefs {
    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.patchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatchesTableFilterComposer
    extends Composer<_$AppDatabase, $PatchesTable> {
  $$PatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scenesRefs(
    Expression<bool> Function($$ScenesTableFilterComposer f) f,
  ) {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.patchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $PatchesTable> {
  $$PatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatchesTable> {
  $$PatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scenesRefs<T extends Object>(
    Expression<T> Function($$ScenesTableAnnotationComposer a) f,
  ) {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.patchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatchesTable,
          Patch,
          $$PatchesTableFilterComposer,
          $$PatchesTableOrderingComposer,
          $$PatchesTableAnnotationComposer,
          $$PatchesTableCreateCompanionBuilder,
          $$PatchesTableUpdateCompanionBuilder,
          (Patch, $$PatchesTableReferences),
          Patch,
          PrefetchHooks Function({bool pedalId, bool scenesRefs})
        > {
  $$PatchesTableTableManager(_$AppDatabase db, $PatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PatchesCompanion(
                id: id,
                pedalId: pedalId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PatchesCompanion.insert(
                id: id,
                pedalId: pedalId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pedalId = false, scenesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scenesRefs) db.scenes],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pedalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pedalId,
                                referencedTable: $$PatchesTableReferences
                                    ._pedalIdTable(db),
                                referencedColumn: $$PatchesTableReferences
                                    ._pedalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scenesRefs)
                    await $_getPrefetchedData<Patch, $PatchesTable, Scene>(
                      currentTable: table,
                      referencedTable: $$PatchesTableReferences
                          ._scenesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PatchesTableReferences(db, table, p0).scenesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.patchId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatchesTable,
      Patch,
      $$PatchesTableFilterComposer,
      $$PatchesTableOrderingComposer,
      $$PatchesTableAnnotationComposer,
      $$PatchesTableCreateCompanionBuilder,
      $$PatchesTableUpdateCompanionBuilder,
      (Patch, $$PatchesTableReferences),
      Patch,
      PrefetchHooks Function({bool pedalId, bool scenesRefs})
    >;
typedef $$ScenesTableCreateCompanionBuilder =
    ScenesCompanion Function({
      Value<int> id,
      required int patchId,
      required String name,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ScenesTableUpdateCompanionBuilder =
    ScenesCompanion Function({
      Value<int> id,
      Value<int> patchId,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ScenesTableReferences
    extends BaseReferences<_$AppDatabase, $ScenesTable, Scene> {
  $$ScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatchesTable _patchIdTable(_$AppDatabase db) =>
      db.patches.createAlias('scenes__patch_id__patches__id');

  $$PatchesTableProcessedTableManager get patchId {
    final $_column = $_itemColumn<int>('patch_id')!;

    final manager = $$PatchesTableTableManager(
      $_db,
      $_db.patches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ScenePedalsTable, List<ScenePedal>>
  _scenePedalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scenePedals,
    aliasName: 'scenes__id__scene_pedals__scene_id',
  );

  $$ScenePedalsTableProcessedTableManager get scenePedalsRefs {
    final manager = $$ScenePedalsTableTableManager(
      $_db,
      $_db.scenePedals,
    ).filter((f) => f.sceneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenePedalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SceneValuesTable, List<SceneValue>>
  _sceneValuesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sceneValues,
    aliasName: 'scenes__id__scene_values__scene_id',
  );

  $$SceneValuesTableProcessedTableManager get sceneValuesRefs {
    final manager = $$SceneValuesTableTableManager(
      $_db,
      $_db.sceneValues,
    ).filter((f) => f.sceneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sceneValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScenesTableFilterComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatchesTableFilterComposer get patchId {
    final $$PatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patchId,
      referencedTable: $db.patches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatchesTableFilterComposer(
            $db: $db,
            $table: $db.patches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scenePedalsRefs(
    Expression<bool> Function($$ScenePedalsTableFilterComposer f) f,
  ) {
    final $$ScenePedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenePedals,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenePedalsTableFilterComposer(
            $db: $db,
            $table: $db.scenePedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sceneValuesRefs(
    Expression<bool> Function($$SceneValuesTableFilterComposer f) f,
  ) {
    final $$SceneValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sceneValues,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SceneValuesTableFilterComposer(
            $db: $db,
            $table: $db.sceneValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatchesTableOrderingComposer get patchId {
    final $$PatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patchId,
      referencedTable: $db.patches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatchesTableOrderingComposer(
            $db: $db,
            $table: $db.patches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PatchesTableAnnotationComposer get patchId {
    final $$PatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patchId,
      referencedTable: $db.patches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.patches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scenePedalsRefs<T extends Object>(
    Expression<T> Function($$ScenePedalsTableAnnotationComposer a) f,
  ) {
    final $$ScenePedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenePedals,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenePedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.scenePedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sceneValuesRefs<T extends Object>(
    Expression<T> Function($$SceneValuesTableAnnotationComposer a) f,
  ) {
    final $$SceneValuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sceneValues,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SceneValuesTableAnnotationComposer(
            $db: $db,
            $table: $db.sceneValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenesTable,
          Scene,
          $$ScenesTableFilterComposer,
          $$ScenesTableOrderingComposer,
          $$ScenesTableAnnotationComposer,
          $$ScenesTableCreateCompanionBuilder,
          $$ScenesTableUpdateCompanionBuilder,
          (Scene, $$ScenesTableReferences),
          Scene,
          PrefetchHooks Function({
            bool patchId,
            bool scenePedalsRefs,
            bool sceneValuesRefs,
          })
        > {
  $$ScenesTableTableManager(_$AppDatabase db, $ScenesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patchId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScenesCompanion(
                id: id,
                patchId: patchId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patchId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ScenesCompanion.insert(
                id: id,
                patchId: patchId,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ScenesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patchId = false,
                scenePedalsRefs = false,
                sceneValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scenePedalsRefs) db.scenePedals,
                    if (sceneValuesRefs) db.sceneValues,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (patchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patchId,
                                    referencedTable: $$ScenesTableReferences
                                        ._patchIdTable(db),
                                    referencedColumn: $$ScenesTableReferences
                                        ._patchIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scenePedalsRefs)
                        await $_getPrefetchedData<
                          Scene,
                          $ScenesTable,
                          ScenePedal
                        >(
                          currentTable: table,
                          referencedTable: $$ScenesTableReferences
                              ._scenePedalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScenesTableReferences(
                                db,
                                table,
                                p0,
                              ).scenePedalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sceneId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sceneValuesRefs)
                        await $_getPrefetchedData<
                          Scene,
                          $ScenesTable,
                          SceneValue
                        >(
                          currentTable: table,
                          referencedTable: $$ScenesTableReferences
                              ._sceneValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScenesTableReferences(
                                db,
                                table,
                                p0,
                              ).sceneValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sceneId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenesTable,
      Scene,
      $$ScenesTableFilterComposer,
      $$ScenesTableOrderingComposer,
      $$ScenesTableAnnotationComposer,
      $$ScenesTableCreateCompanionBuilder,
      $$ScenesTableUpdateCompanionBuilder,
      (Scene, $$ScenesTableReferences),
      Scene,
      PrefetchHooks Function({
        bool patchId,
        bool scenePedalsRefs,
        bool sceneValuesRefs,
      })
    >;
typedef $$ScenePedalsTableCreateCompanionBuilder =
    ScenePedalsCompanion Function({
      Value<int> id,
      required int sceneId,
      required int pedalId,
    });
typedef $$ScenePedalsTableUpdateCompanionBuilder =
    ScenePedalsCompanion Function({
      Value<int> id,
      Value<int> sceneId,
      Value<int> pedalId,
    });

final class $$ScenePedalsTableReferences
    extends BaseReferences<_$AppDatabase, $ScenePedalsTable, ScenePedal> {
  $$ScenePedalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScenesTable _sceneIdTable(_$AppDatabase db) =>
      db.scenes.createAlias('scene_pedals__scene_id__scenes__id');

  $$ScenesTableProcessedTableManager get sceneId {
    final $_column = $_itemColumn<int>('scene_id')!;

    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sceneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('scene_pedals__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScenePedalsTableFilterComposer
    extends Composer<_$AppDatabase, $ScenePedalsTable> {
  $$ScenePedalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ScenesTableFilterComposer get sceneId {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenePedalsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenePedalsTable> {
  $$ScenePedalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScenesTableOrderingComposer get sceneId {
    final $$ScenesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableOrderingComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenePedalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenePedalsTable> {
  $$ScenePedalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ScenesTableAnnotationComposer get sceneId {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenePedalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenePedalsTable,
          ScenePedal,
          $$ScenePedalsTableFilterComposer,
          $$ScenePedalsTableOrderingComposer,
          $$ScenePedalsTableAnnotationComposer,
          $$ScenePedalsTableCreateCompanionBuilder,
          $$ScenePedalsTableUpdateCompanionBuilder,
          (ScenePedal, $$ScenePedalsTableReferences),
          ScenePedal,
          PrefetchHooks Function({bool sceneId, bool pedalId})
        > {
  $$ScenePedalsTableTableManager(_$AppDatabase db, $ScenePedalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenePedalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenePedalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenePedalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sceneId = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
              }) => ScenePedalsCompanion(
                id: id,
                sceneId: sceneId,
                pedalId: pedalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sceneId,
                required int pedalId,
              }) => ScenePedalsCompanion.insert(
                id: id,
                sceneId: sceneId,
                pedalId: pedalId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScenePedalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sceneId = false, pedalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sceneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sceneId,
                                referencedTable: $$ScenePedalsTableReferences
                                    ._sceneIdTable(db),
                                referencedColumn: $$ScenePedalsTableReferences
                                    ._sceneIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (pedalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pedalId,
                                referencedTable: $$ScenePedalsTableReferences
                                    ._pedalIdTable(db),
                                referencedColumn: $$ScenePedalsTableReferences
                                    ._pedalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScenePedalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenePedalsTable,
      ScenePedal,
      $$ScenePedalsTableFilterComposer,
      $$ScenePedalsTableOrderingComposer,
      $$ScenePedalsTableAnnotationComposer,
      $$ScenePedalsTableCreateCompanionBuilder,
      $$ScenePedalsTableUpdateCompanionBuilder,
      (ScenePedal, $$ScenePedalsTableReferences),
      ScenePedal,
      PrefetchHooks Function({bool sceneId, bool pedalId})
    >;
typedef $$SceneValuesTableCreateCompanionBuilder =
    SceneValuesCompanion Function({
      Value<int> id,
      required int sceneId,
      required int controlId,
      required double value,
    });
typedef $$SceneValuesTableUpdateCompanionBuilder =
    SceneValuesCompanion Function({
      Value<int> id,
      Value<int> sceneId,
      Value<int> controlId,
      Value<double> value,
    });

final class $$SceneValuesTableReferences
    extends BaseReferences<_$AppDatabase, $SceneValuesTable, SceneValue> {
  $$SceneValuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScenesTable _sceneIdTable(_$AppDatabase db) =>
      db.scenes.createAlias('scene_values__scene_id__scenes__id');

  $$ScenesTableProcessedTableManager get sceneId {
    final $_column = $_itemColumn<int>('scene_id')!;

    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sceneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalControlsTable _controlIdTable(_$AppDatabase db) => db
      .pedalControls
      .createAlias('scene_values__control_id__pedal_controls__id');

  $$PedalControlsTableProcessedTableManager get controlId {
    final $_column = $_itemColumn<int>('control_id')!;

    final manager = $$PedalControlsTableTableManager(
      $_db,
      $_db.pedalControls,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_controlIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SceneValuesTableFilterComposer
    extends Composer<_$AppDatabase, $SceneValuesTable> {
  $$SceneValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$ScenesTableFilterComposer get sceneId {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableFilterComposer get controlId {
    final $$PedalControlsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableFilterComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SceneValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SceneValuesTable> {
  $$SceneValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScenesTableOrderingComposer get sceneId {
    final $$ScenesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableOrderingComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableOrderingComposer get controlId {
    final $$PedalControlsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SceneValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SceneValuesTable> {
  $$SceneValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$ScenesTableAnnotationComposer get sceneId {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableAnnotationComposer get controlId {
    final $$PedalControlsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SceneValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SceneValuesTable,
          SceneValue,
          $$SceneValuesTableFilterComposer,
          $$SceneValuesTableOrderingComposer,
          $$SceneValuesTableAnnotationComposer,
          $$SceneValuesTableCreateCompanionBuilder,
          $$SceneValuesTableUpdateCompanionBuilder,
          (SceneValue, $$SceneValuesTableReferences),
          SceneValue,
          PrefetchHooks Function({bool sceneId, bool controlId})
        > {
  $$SceneValuesTableTableManager(_$AppDatabase db, $SceneValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SceneValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SceneValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SceneValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sceneId = const Value.absent(),
                Value<int> controlId = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => SceneValuesCompanion(
                id: id,
                sceneId: sceneId,
                controlId: controlId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sceneId,
                required int controlId,
                required double value,
              }) => SceneValuesCompanion.insert(
                id: id,
                sceneId: sceneId,
                controlId: controlId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SceneValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sceneId = false, controlId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sceneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sceneId,
                                referencedTable: $$SceneValuesTableReferences
                                    ._sceneIdTable(db),
                                referencedColumn: $$SceneValuesTableReferences
                                    ._sceneIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (controlId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.controlId,
                                referencedTable: $$SceneValuesTableReferences
                                    ._controlIdTable(db),
                                referencedColumn: $$SceneValuesTableReferences
                                    ._controlIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SceneValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SceneValuesTable,
      SceneValue,
      $$SceneValuesTableFilterComposer,
      $$SceneValuesTableOrderingComposer,
      $$SceneValuesTableAnnotationComposer,
      $$SceneValuesTableCreateCompanionBuilder,
      $$SceneValuesTableUpdateCompanionBuilder,
      (SceneValue, $$SceneValuesTableReferences),
      SceneValue,
      PrefetchHooks Function({bool sceneId, bool controlId})
    >;
typedef $$ChangeLogsTableCreateCompanionBuilder =
    ChangeLogsCompanion Function({
      Value<int> id,
      required int pedalId,
      Value<int?> configurationId,
      Value<int?> controlId,
      Value<String?> configurationName,
      Value<String?> controlName,
      Value<String?> controlPedalName,
      required ChangeType changeType,
      Value<double?> oldValue,
      Value<double?> newValue,
      Value<String?> oldText,
      Value<String?> newText,
      Value<String?> reason,
      required DateTime createdAt,
    });
typedef $$ChangeLogsTableUpdateCompanionBuilder =
    ChangeLogsCompanion Function({
      Value<int> id,
      Value<int> pedalId,
      Value<int?> configurationId,
      Value<int?> controlId,
      Value<String?> configurationName,
      Value<String?> controlName,
      Value<String?> controlPedalName,
      Value<ChangeType> changeType,
      Value<double?> oldValue,
      Value<double?> newValue,
      Value<String?> oldText,
      Value<String?> newText,
      Value<String?> reason,
      Value<DateTime> createdAt,
    });

final class $$ChangeLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ChangeLogsTable, ChangeLog> {
  $$ChangeLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('change_logs__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConfigurationsTable _configurationIdTable(_$AppDatabase db) => db
      .configurations
      .createAlias('change_logs__configuration_id__configurations__id');

  $$ConfigurationsTableProcessedTableManager? get configurationId {
    final $_column = $_itemColumn<int>('configuration_id');
    if ($_column == null) return null;
    final manager = $$ConfigurationsTableTableManager(
      $_db,
      $_db.configurations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_configurationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalControlsTable _controlIdTable(_$AppDatabase db) => db
      .pedalControls
      .createAlias('change_logs__control_id__pedal_controls__id');

  $$PedalControlsTableProcessedTableManager? get controlId {
    final $_column = $_itemColumn<int>('control_id');
    if ($_column == null) return null;
    final manager = $$PedalControlsTableTableManager(
      $_db,
      $_db.pedalControls,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_controlIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChangeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChangeType, ChangeType, String>
  get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldText => $composableBuilder(
    column: $table.oldText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newText => $composableBuilder(
    column: $table.newText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigurationsTableFilterComposer get configurationId {
    final $$ConfigurationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableFilterComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableFilterComposer get controlId {
    final $$PedalControlsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableFilterComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChangeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldText => $composableBuilder(
    column: $table.oldText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newText => $composableBuilder(
    column: $table.newText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigurationsTableOrderingComposer get configurationId {
    final $$ConfigurationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableOrderingComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableOrderingComposer get controlId {
    final $$PedalControlsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChangeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ChangeType, String> get changeType =>
      $composableBuilder(
        column: $table.changeType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<double> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get oldText =>
      $composableBuilder(column: $table.oldText, builder: (column) => column);

  GeneratedColumn<String> get newText =>
      $composableBuilder(column: $table.newText, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigurationsTableAnnotationComposer get configurationId {
    final $$ConfigurationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configurationId,
      referencedTable: $db.configurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigurationsTableAnnotationComposer(
            $db: $db,
            $table: $db.configurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalControlsTableAnnotationComposer get controlId {
    final $$PedalControlsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.controlId,
      referencedTable: $db.pedalControls,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalControlsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalControls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChangeLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeLogsTable,
          ChangeLog,
          $$ChangeLogsTableFilterComposer,
          $$ChangeLogsTableOrderingComposer,
          $$ChangeLogsTableAnnotationComposer,
          $$ChangeLogsTableCreateCompanionBuilder,
          $$ChangeLogsTableUpdateCompanionBuilder,
          (ChangeLog, $$ChangeLogsTableReferences),
          ChangeLog,
          PrefetchHooks Function({
            bool pedalId,
            bool configurationId,
            bool controlId,
          })
        > {
  $$ChangeLogsTableTableManager(_$AppDatabase db, $ChangeLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
                Value<int?> configurationId = const Value.absent(),
                Value<int?> controlId = const Value.absent(),
                Value<String?> configurationName = const Value.absent(),
                Value<String?> controlName = const Value.absent(),
                Value<String?> controlPedalName = const Value.absent(),
                Value<ChangeType> changeType = const Value.absent(),
                Value<double?> oldValue = const Value.absent(),
                Value<double?> newValue = const Value.absent(),
                Value<String?> oldText = const Value.absent(),
                Value<String?> newText = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChangeLogsCompanion(
                id: id,
                pedalId: pedalId,
                configurationId: configurationId,
                controlId: controlId,
                configurationName: configurationName,
                controlName: controlName,
                controlPedalName: controlPedalName,
                changeType: changeType,
                oldValue: oldValue,
                newValue: newValue,
                oldText: oldText,
                newText: newText,
                reason: reason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalId,
                Value<int?> configurationId = const Value.absent(),
                Value<int?> controlId = const Value.absent(),
                Value<String?> configurationName = const Value.absent(),
                Value<String?> controlName = const Value.absent(),
                Value<String?> controlPedalName = const Value.absent(),
                required ChangeType changeType,
                Value<double?> oldValue = const Value.absent(),
                Value<double?> newValue = const Value.absent(),
                Value<String?> oldText = const Value.absent(),
                Value<String?> newText = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
              }) => ChangeLogsCompanion.insert(
                id: id,
                pedalId: pedalId,
                configurationId: configurationId,
                controlId: controlId,
                configurationName: configurationName,
                controlName: controlName,
                controlPedalName: controlPedalName,
                changeType: changeType,
                oldValue: oldValue,
                newValue: newValue,
                oldText: oldText,
                newText: newText,
                reason: reason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChangeLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({pedalId = false, configurationId = false, controlId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalId,
                                    referencedTable: $$ChangeLogsTableReferences
                                        ._pedalIdTable(db),
                                    referencedColumn:
                                        $$ChangeLogsTableReferences
                                            ._pedalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (configurationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.configurationId,
                                    referencedTable: $$ChangeLogsTableReferences
                                        ._configurationIdTable(db),
                                    referencedColumn:
                                        $$ChangeLogsTableReferences
                                            ._configurationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (controlId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.controlId,
                                    referencedTable: $$ChangeLogsTableReferences
                                        ._controlIdTable(db),
                                    referencedColumn:
                                        $$ChangeLogsTableReferences
                                            ._controlIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ChangeLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeLogsTable,
      ChangeLog,
      $$ChangeLogsTableFilterComposer,
      $$ChangeLogsTableOrderingComposer,
      $$ChangeLogsTableAnnotationComposer,
      $$ChangeLogsTableCreateCompanionBuilder,
      $$ChangeLogsTableUpdateCompanionBuilder,
      (ChangeLog, $$ChangeLogsTableReferences),
      ChangeLog,
      PrefetchHooks Function({
        bool pedalId,
        bool configurationId,
        bool controlId,
      })
    >;
typedef $$PedalReplacementsTableCreateCompanionBuilder =
    PedalReplacementsCompanion Function({
      Value<int> id,
      required int oldPedalId,
      required int newPedalId,
      Value<String?> reason,
      required DateTime replacedAt,
      Value<String?> notes,
    });
typedef $$PedalReplacementsTableUpdateCompanionBuilder =
    PedalReplacementsCompanion Function({
      Value<int> id,
      Value<int> oldPedalId,
      Value<int> newPedalId,
      Value<String?> reason,
      Value<DateTime> replacedAt,
      Value<String?> notes,
    });

final class $$PedalReplacementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PedalReplacementsTable,
          PedalReplacement
        > {
  $$PedalReplacementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PedalsTable _oldPedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('pedal_replacements__old_pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get oldPedalId {
    final $_column = $_itemColumn<int>('old_pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_oldPedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalsTable _newPedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('pedal_replacements__new_pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get newPedalId {
    final $_column = $_itemColumn<int>('new_pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_newPedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PedalReplacementsTableFilterComposer
    extends Composer<_$AppDatabase, $PedalReplacementsTable> {
  $$PedalReplacementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get replacedAt => $composableBuilder(
    column: $table.replacedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalsTableFilterComposer get oldPedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.oldPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableFilterComposer get newPedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PedalReplacementsTableOrderingComposer
    extends Composer<_$AppDatabase, $PedalReplacementsTable> {
  $$PedalReplacementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get replacedAt => $composableBuilder(
    column: $table.replacedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalsTableOrderingComposer get oldPedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.oldPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableOrderingComposer get newPedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PedalReplacementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedalReplacementsTable> {
  $$PedalReplacementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get replacedAt => $composableBuilder(
    column: $table.replacedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PedalsTableAnnotationComposer get oldPedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.oldPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableAnnotationComposer get newPedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newPedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PedalReplacementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedalReplacementsTable,
          PedalReplacement,
          $$PedalReplacementsTableFilterComposer,
          $$PedalReplacementsTableOrderingComposer,
          $$PedalReplacementsTableAnnotationComposer,
          $$PedalReplacementsTableCreateCompanionBuilder,
          $$PedalReplacementsTableUpdateCompanionBuilder,
          (PedalReplacement, $$PedalReplacementsTableReferences),
          PedalReplacement,
          PrefetchHooks Function({bool oldPedalId, bool newPedalId})
        > {
  $$PedalReplacementsTableTableManager(
    _$AppDatabase db,
    $PedalReplacementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedalReplacementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedalReplacementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedalReplacementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> oldPedalId = const Value.absent(),
                Value<int> newPedalId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> replacedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PedalReplacementsCompanion(
                id: id,
                oldPedalId: oldPedalId,
                newPedalId: newPedalId,
                reason: reason,
                replacedAt: replacedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int oldPedalId,
                required int newPedalId,
                Value<String?> reason = const Value.absent(),
                required DateTime replacedAt,
                Value<String?> notes = const Value.absent(),
              }) => PedalReplacementsCompanion.insert(
                id: id,
                oldPedalId: oldPedalId,
                newPedalId: newPedalId,
                reason: reason,
                replacedAt: replacedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PedalReplacementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({oldPedalId = false, newPedalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (oldPedalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.oldPedalId,
                                referencedTable:
                                    $$PedalReplacementsTableReferences
                                        ._oldPedalIdTable(db),
                                referencedColumn:
                                    $$PedalReplacementsTableReferences
                                        ._oldPedalIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (newPedalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.newPedalId,
                                referencedTable:
                                    $$PedalReplacementsTableReferences
                                        ._newPedalIdTable(db),
                                referencedColumn:
                                    $$PedalReplacementsTableReferences
                                        ._newPedalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PedalReplacementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedalReplacementsTable,
      PedalReplacement,
      $$PedalReplacementsTableFilterComposer,
      $$PedalReplacementsTableOrderingComposer,
      $$PedalReplacementsTableAnnotationComposer,
      $$PedalReplacementsTableCreateCompanionBuilder,
      $$PedalReplacementsTableUpdateCompanionBuilder,
      (PedalReplacement, $$PedalReplacementsTableReferences),
      PedalReplacement,
      PrefetchHooks Function({bool oldPedalId, bool newPedalId})
    >;
typedef $$PedalboardsTableCreateCompanionBuilder =
    PedalboardsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PedalboardsTableUpdateCompanionBuilder =
    PedalboardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PedalboardsTableReferences
    extends BaseReferences<_$AppDatabase, $PedalboardsTable, Pedalboard> {
  $$PedalboardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SignalBlocksTable, List<SignalBlock>>
  _signalBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalBlocks,
    aliasName: 'pedalboards__id__signal_blocks__pedalboard_id',
  );

  $$SignalBlocksTableProcessedTableManager get signalBlocksRefs {
    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.pedalboardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalConnectionsTable, List<SignalConnection>>
  _signalConnectionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.signalConnections,
        aliasName: 'pedalboards__id__signal_connections__pedalboard_id',
      );

  $$SignalConnectionsTableProcessedTableManager get signalConnectionsRefs {
    final manager = $$SignalConnectionsTableTableManager(
      $_db,
      $_db.signalConnections,
    ).filter((f) => f.pedalboardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _signalConnectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RigSnapshotsTable, List<RigSnapshot>>
  _rigSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rigSnapshots,
    aliasName: 'pedalboards__id__rig_snapshots__pedalboard_id',
  );

  $$RigSnapshotsTableProcessedTableManager get rigSnapshotsRefs {
    final manager = $$RigSnapshotsTableTableManager(
      $_db,
      $_db.rigSnapshots,
    ).filter((f) => f.pedalboardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rigSnapshotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PedalboardsTableFilterComposer
    extends Composer<_$AppDatabase, $PedalboardsTable> {
  $$PedalboardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> signalBlocksRefs(
    Expression<bool> Function($$SignalBlocksTableFilterComposer f) f,
  ) {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.pedalboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> signalConnectionsRefs(
    Expression<bool> Function($$SignalConnectionsTableFilterComposer f) f,
  ) {
    final $$SignalConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalConnections,
      getReferencedColumn: (t) => t.pedalboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.signalConnections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rigSnapshotsRefs(
    Expression<bool> Function($$RigSnapshotsTableFilterComposer f) f,
  ) {
    final $$RigSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rigSnapshots,
      getReferencedColumn: (t) => t.pedalboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedalboardsTableOrderingComposer
    extends Composer<_$AppDatabase, $PedalboardsTable> {
  $$PedalboardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PedalboardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedalboardsTable> {
  $$PedalboardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> signalBlocksRefs<T extends Object>(
    Expression<T> Function($$SignalBlocksTableAnnotationComposer a) f,
  ) {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.pedalboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> signalConnectionsRefs<T extends Object>(
    Expression<T> Function($$SignalConnectionsTableAnnotationComposer a) f,
  ) {
    final $$SignalConnectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.signalConnections,
          getReferencedColumn: (t) => t.pedalboardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SignalConnectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.signalConnections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> rigSnapshotsRefs<T extends Object>(
    Expression<T> Function($$RigSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$RigSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rigSnapshots,
      getReferencedColumn: (t) => t.pedalboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.rigSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedalboardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedalboardsTable,
          Pedalboard,
          $$PedalboardsTableFilterComposer,
          $$PedalboardsTableOrderingComposer,
          $$PedalboardsTableAnnotationComposer,
          $$PedalboardsTableCreateCompanionBuilder,
          $$PedalboardsTableUpdateCompanionBuilder,
          (Pedalboard, $$PedalboardsTableReferences),
          Pedalboard,
          PrefetchHooks Function({
            bool signalBlocksRefs,
            bool signalConnectionsRefs,
            bool rigSnapshotsRefs,
          })
        > {
  $$PedalboardsTableTableManager(_$AppDatabase db, $PedalboardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedalboardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedalboardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedalboardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PedalboardsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PedalboardsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PedalboardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                signalBlocksRefs = false,
                signalConnectionsRefs = false,
                rigSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (signalBlocksRefs) db.signalBlocks,
                    if (signalConnectionsRefs) db.signalConnections,
                    if (rigSnapshotsRefs) db.rigSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (signalBlocksRefs)
                        await $_getPrefetchedData<
                          Pedalboard,
                          $PedalboardsTable,
                          SignalBlock
                        >(
                          currentTable: table,
                          referencedTable: $$PedalboardsTableReferences
                              ._signalBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalboardsTableReferences(
                                db,
                                table,
                                p0,
                              ).signalBlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalboardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (signalConnectionsRefs)
                        await $_getPrefetchedData<
                          Pedalboard,
                          $PedalboardsTable,
                          SignalConnection
                        >(
                          currentTable: table,
                          referencedTable: $$PedalboardsTableReferences
                              ._signalConnectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalboardsTableReferences(
                                db,
                                table,
                                p0,
                              ).signalConnectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalboardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rigSnapshotsRefs)
                        await $_getPrefetchedData<
                          Pedalboard,
                          $PedalboardsTable,
                          RigSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$PedalboardsTableReferences
                              ._rigSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PedalboardsTableReferences(
                                db,
                                table,
                                p0,
                              ).rigSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pedalboardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PedalboardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedalboardsTable,
      Pedalboard,
      $$PedalboardsTableFilterComposer,
      $$PedalboardsTableOrderingComposer,
      $$PedalboardsTableAnnotationComposer,
      $$PedalboardsTableCreateCompanionBuilder,
      $$PedalboardsTableUpdateCompanionBuilder,
      (Pedalboard, $$PedalboardsTableReferences),
      Pedalboard,
      PrefetchHooks Function({
        bool signalBlocksRefs,
        bool signalConnectionsRefs,
        bool rigSnapshotsRefs,
      })
    >;
typedef $$SignalBlocksTableCreateCompanionBuilder =
    SignalBlocksCompanion Function({
      Value<int> id,
      required int pedalboardId,
      Value<int?> pedalId,
      required SignalBlockType blockType,
      Value<String?> label,
      required int position,
      Value<bool> isEnabled,
      Value<String?> notes,
    });
typedef $$SignalBlocksTableUpdateCompanionBuilder =
    SignalBlocksCompanion Function({
      Value<int> id,
      Value<int> pedalboardId,
      Value<int?> pedalId,
      Value<SignalBlockType> blockType,
      Value<String?> label,
      Value<int> position,
      Value<bool> isEnabled,
      Value<String?> notes,
    });

final class $$SignalBlocksTableReferences
    extends BaseReferences<_$AppDatabase, $SignalBlocksTable, SignalBlock> {
  $$SignalBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedalboardsTable _pedalboardIdTable(_$AppDatabase db) => db
      .pedalboards
      .createAlias('signal_blocks__pedalboard_id__pedalboards__id');

  $$PedalboardsTableProcessedTableManager get pedalboardId {
    final $_column = $_itemColumn<int>('pedalboard_id')!;

    final manager = $$PedalboardsTableTableManager(
      $_db,
      $_db.pedalboards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalboardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('signal_blocks__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager? get pedalId {
    final $_column = $_itemColumn<int>('pedal_id');
    if ($_column == null) return null;
    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SignalConnectionsTable, List<SignalConnection>>
  _outgoingConnectionsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalConnections,
    aliasName: 'signal_blocks__id__signal_connections__source_block_id',
  );

  $$SignalConnectionsTableProcessedTableManager get outgoingConnections {
    final manager = $$SignalConnectionsTableTableManager(
      $_db,
      $_db.signalConnections,
    ).filter((f) => f.sourceBlockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _outgoingConnectionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalConnectionsTable, List<SignalConnection>>
  _incomingConnectionsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalConnections,
    aliasName: 'signal_blocks__id__signal_connections__target_block_id',
  );

  $$SignalConnectionsTableProcessedTableManager get incomingConnections {
    final manager = $$SignalConnectionsTableTableManager(
      $_db,
      $_db.signalConnections,
    ).filter((f) => f.targetBlockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomingConnectionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalEndpointsTable, List<SignalEndpoint>>
  _endpointsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalEndpoints,
    aliasName: 'signal_blocks__id__signal_endpoints__block_id',
  );

  $$SignalEndpointsTableProcessedTableManager get endpoints {
    final manager = $$SignalEndpointsTableTableManager(
      $_db,
      $_db.signalEndpoints,
    ).filter((f) => f.blockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_endpointsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalEndpointsTable, List<SignalEndpoint>>
  _pairingsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.signalEndpoints,
    aliasName: 'signal_blocks__id__signal_endpoints__paired_block_id',
  );

  $$SignalEndpointsTableProcessedTableManager get pairings {
    final manager = $$SignalEndpointsTableTableManager(
      $_db,
      $_db.signalEndpoints,
    ).filter((f) => f.pairedBlockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairingsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SignalBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $SignalBlocksTable> {
  $$SignalBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SignalBlockType, SignalBlockType, String>
  get blockType => $composableBuilder(
    column: $table.blockType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalboardsTableFilterComposer get pedalboardId {
    final $$PedalboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableFilterComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> outgoingConnections(
    Expression<bool> Function($$SignalConnectionsTableFilterComposer f) f,
  ) {
    final $$SignalConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalConnections,
      getReferencedColumn: (t) => t.sourceBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.signalConnections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingConnections(
    Expression<bool> Function($$SignalConnectionsTableFilterComposer f) f,
  ) {
    final $$SignalConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalConnections,
      getReferencedColumn: (t) => t.targetBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.signalConnections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> endpoints(
    Expression<bool> Function($$SignalEndpointsTableFilterComposer f) f,
  ) {
    final $$SignalEndpointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEndpoints,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEndpointsTableFilterComposer(
            $db: $db,
            $table: $db.signalEndpoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pairings(
    Expression<bool> Function($$SignalEndpointsTableFilterComposer f) f,
  ) {
    final $$SignalEndpointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEndpoints,
      getReferencedColumn: (t) => t.pairedBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEndpointsTableFilterComposer(
            $db: $db,
            $table: $db.signalEndpoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SignalBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $SignalBlocksTable> {
  $$SignalBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockType => $composableBuilder(
    column: $table.blockType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalboardsTableOrderingComposer get pedalboardId {
    final $$PedalboardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignalBlocksTable> {
  $$SignalBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalBlockType, String> get blockType =>
      $composableBuilder(column: $table.blockType, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PedalboardsTableAnnotationComposer get pedalboardId {
    final $$PedalboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> outgoingConnections<T extends Object>(
    Expression<T> Function($$SignalConnectionsTableAnnotationComposer a) f,
  ) {
    final $$SignalConnectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.signalConnections,
          getReferencedColumn: (t) => t.sourceBlockId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SignalConnectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.signalConnections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> incomingConnections<T extends Object>(
    Expression<T> Function($$SignalConnectionsTableAnnotationComposer a) f,
  ) {
    final $$SignalConnectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.signalConnections,
          getReferencedColumn: (t) => t.targetBlockId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SignalConnectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.signalConnections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> endpoints<T extends Object>(
    Expression<T> Function($$SignalEndpointsTableAnnotationComposer a) f,
  ) {
    final $$SignalEndpointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEndpoints,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEndpointsTableAnnotationComposer(
            $db: $db,
            $table: $db.signalEndpoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pairings<T extends Object>(
    Expression<T> Function($$SignalEndpointsTableAnnotationComposer a) f,
  ) {
    final $$SignalEndpointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEndpoints,
      getReferencedColumn: (t) => t.pairedBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEndpointsTableAnnotationComposer(
            $db: $db,
            $table: $db.signalEndpoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SignalBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SignalBlocksTable,
          SignalBlock,
          $$SignalBlocksTableFilterComposer,
          $$SignalBlocksTableOrderingComposer,
          $$SignalBlocksTableAnnotationComposer,
          $$SignalBlocksTableCreateCompanionBuilder,
          $$SignalBlocksTableUpdateCompanionBuilder,
          (SignalBlock, $$SignalBlocksTableReferences),
          SignalBlock,
          PrefetchHooks Function({
            bool pedalboardId,
            bool pedalId,
            bool outgoingConnections,
            bool incomingConnections,
            bool endpoints,
            bool pairings,
          })
        > {
  $$SignalBlocksTableTableManager(_$AppDatabase db, $SignalBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalboardId = const Value.absent(),
                Value<int?> pedalId = const Value.absent(),
                Value<SignalBlockType> blockType = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SignalBlocksCompanion(
                id: id,
                pedalboardId: pedalboardId,
                pedalId: pedalId,
                blockType: blockType,
                label: label,
                position: position,
                isEnabled: isEnabled,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalboardId,
                Value<int?> pedalId = const Value.absent(),
                required SignalBlockType blockType,
                Value<String?> label = const Value.absent(),
                required int position,
                Value<bool> isEnabled = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SignalBlocksCompanion.insert(
                id: id,
                pedalboardId: pedalboardId,
                pedalId: pedalId,
                blockType: blockType,
                label: label,
                position: position,
                isEnabled: isEnabled,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SignalBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pedalboardId = false,
                pedalId = false,
                outgoingConnections = false,
                incomingConnections = false,
                endpoints = false,
                pairings = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (outgoingConnections) db.signalConnections,
                    if (incomingConnections) db.signalConnections,
                    if (endpoints) db.signalEndpoints,
                    if (pairings) db.signalEndpoints,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalboardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalboardId,
                                    referencedTable:
                                        $$SignalBlocksTableReferences
                                            ._pedalboardIdTable(db),
                                    referencedColumn:
                                        $$SignalBlocksTableReferences
                                            ._pedalboardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (pedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalId,
                                    referencedTable:
                                        $$SignalBlocksTableReferences
                                            ._pedalIdTable(db),
                                    referencedColumn:
                                        $$SignalBlocksTableReferences
                                            ._pedalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (outgoingConnections)
                        await $_getPrefetchedData<
                          SignalBlock,
                          $SignalBlocksTable,
                          SignalConnection
                        >(
                          currentTable: table,
                          referencedTable: $$SignalBlocksTableReferences
                              ._outgoingConnectionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalBlocksTableReferences(
                                db,
                                table,
                                p0,
                              ).outgoingConnections,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceBlockId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomingConnections)
                        await $_getPrefetchedData<
                          SignalBlock,
                          $SignalBlocksTable,
                          SignalConnection
                        >(
                          currentTable: table,
                          referencedTable: $$SignalBlocksTableReferences
                              ._incomingConnectionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalBlocksTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingConnections,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetBlockId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (endpoints)
                        await $_getPrefetchedData<
                          SignalBlock,
                          $SignalBlocksTable,
                          SignalEndpoint
                        >(
                          currentTable: table,
                          referencedTable: $$SignalBlocksTableReferences
                              ._endpointsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalBlocksTableReferences(
                                db,
                                table,
                                p0,
                              ).endpoints,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.blockId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pairings)
                        await $_getPrefetchedData<
                          SignalBlock,
                          $SignalBlocksTable,
                          SignalEndpoint
                        >(
                          currentTable: table,
                          referencedTable: $$SignalBlocksTableReferences
                              ._pairingsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalBlocksTableReferences(
                                db,
                                table,
                                p0,
                              ).pairings,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pairedBlockId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SignalBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SignalBlocksTable,
      SignalBlock,
      $$SignalBlocksTableFilterComposer,
      $$SignalBlocksTableOrderingComposer,
      $$SignalBlocksTableAnnotationComposer,
      $$SignalBlocksTableCreateCompanionBuilder,
      $$SignalBlocksTableUpdateCompanionBuilder,
      (SignalBlock, $$SignalBlocksTableReferences),
      SignalBlock,
      PrefetchHooks Function({
        bool pedalboardId,
        bool pedalId,
        bool outgoingConnections,
        bool incomingConnections,
        bool endpoints,
        bool pairings,
      })
    >;
typedef $$SignalConnectionsTableCreateCompanionBuilder =
    SignalConnectionsCompanion Function({
      Value<int> id,
      required int pedalboardId,
      required int sourceBlockId,
      required int targetBlockId,
      required SignalConnectionType connectionType,
    });
typedef $$SignalConnectionsTableUpdateCompanionBuilder =
    SignalConnectionsCompanion Function({
      Value<int> id,
      Value<int> pedalboardId,
      Value<int> sourceBlockId,
      Value<int> targetBlockId,
      Value<SignalConnectionType> connectionType,
    });

final class $$SignalConnectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SignalConnectionsTable,
          SignalConnection
        > {
  $$SignalConnectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PedalboardsTable _pedalboardIdTable(_$AppDatabase db) => db
      .pedalboards
      .createAlias('signal_connections__pedalboard_id__pedalboards__id');

  $$PedalboardsTableProcessedTableManager get pedalboardId {
    final $_column = $_itemColumn<int>('pedalboard_id')!;

    final manager = $$PedalboardsTableTableManager(
      $_db,
      $_db.pedalboards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalboardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalBlocksTable _sourceBlockIdTable(_$AppDatabase db) => db
      .signalBlocks
      .createAlias('signal_connections__source_block_id__signal_blocks__id');

  $$SignalBlocksTableProcessedTableManager get sourceBlockId {
    final $_column = $_itemColumn<int>('source_block_id')!;

    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceBlockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalBlocksTable _targetBlockIdTable(_$AppDatabase db) => db
      .signalBlocks
      .createAlias('signal_connections__target_block_id__signal_blocks__id');

  $$SignalBlocksTableProcessedTableManager get targetBlockId {
    final $_column = $_itemColumn<int>('target_block_id')!;

    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetBlockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SignalConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SignalConnectionsTable> {
  $$SignalConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SignalConnectionType,
    SignalConnectionType,
    String
  >
  get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$PedalboardsTableFilterComposer get pedalboardId {
    final $$PedalboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableFilterComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableFilterComposer get sourceBlockId {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableFilterComposer get targetBlockId {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SignalConnectionsTable> {
  $$SignalConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalboardsTableOrderingComposer get pedalboardId {
    final $$PedalboardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableOrderingComposer get sourceBlockId {
    final $$SignalBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableOrderingComposer get targetBlockId {
    final $$SignalBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignalConnectionsTable> {
  $$SignalConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalConnectionType, String>
  get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => column,
  );

  $$PedalboardsTableAnnotationComposer get pedalboardId {
    final $$PedalboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableAnnotationComposer get sourceBlockId {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableAnnotationComposer get targetBlockId {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SignalConnectionsTable,
          SignalConnection,
          $$SignalConnectionsTableFilterComposer,
          $$SignalConnectionsTableOrderingComposer,
          $$SignalConnectionsTableAnnotationComposer,
          $$SignalConnectionsTableCreateCompanionBuilder,
          $$SignalConnectionsTableUpdateCompanionBuilder,
          (SignalConnection, $$SignalConnectionsTableReferences),
          SignalConnection,
          PrefetchHooks Function({
            bool pedalboardId,
            bool sourceBlockId,
            bool targetBlockId,
          })
        > {
  $$SignalConnectionsTableTableManager(
    _$AppDatabase db,
    $SignalConnectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalConnectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalboardId = const Value.absent(),
                Value<int> sourceBlockId = const Value.absent(),
                Value<int> targetBlockId = const Value.absent(),
                Value<SignalConnectionType> connectionType =
                    const Value.absent(),
              }) => SignalConnectionsCompanion(
                id: id,
                pedalboardId: pedalboardId,
                sourceBlockId: sourceBlockId,
                targetBlockId: targetBlockId,
                connectionType: connectionType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalboardId,
                required int sourceBlockId,
                required int targetBlockId,
                required SignalConnectionType connectionType,
              }) => SignalConnectionsCompanion.insert(
                id: id,
                pedalboardId: pedalboardId,
                sourceBlockId: sourceBlockId,
                targetBlockId: targetBlockId,
                connectionType: connectionType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SignalConnectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pedalboardId = false,
                sourceBlockId = false,
                targetBlockId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalboardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalboardId,
                                    referencedTable:
                                        $$SignalConnectionsTableReferences
                                            ._pedalboardIdTable(db),
                                    referencedColumn:
                                        $$SignalConnectionsTableReferences
                                            ._pedalboardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceBlockId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceBlockId,
                                    referencedTable:
                                        $$SignalConnectionsTableReferences
                                            ._sourceBlockIdTable(db),
                                    referencedColumn:
                                        $$SignalConnectionsTableReferences
                                            ._sourceBlockIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetBlockId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetBlockId,
                                    referencedTable:
                                        $$SignalConnectionsTableReferences
                                            ._targetBlockIdTable(db),
                                    referencedColumn:
                                        $$SignalConnectionsTableReferences
                                            ._targetBlockIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$SignalConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SignalConnectionsTable,
      SignalConnection,
      $$SignalConnectionsTableFilterComposer,
      $$SignalConnectionsTableOrderingComposer,
      $$SignalConnectionsTableAnnotationComposer,
      $$SignalConnectionsTableCreateCompanionBuilder,
      $$SignalConnectionsTableUpdateCompanionBuilder,
      (SignalConnection, $$SignalConnectionsTableReferences),
      SignalConnection,
      PrefetchHooks Function({
        bool pedalboardId,
        bool sourceBlockId,
        bool targetBlockId,
      })
    >;
typedef $$SignalEndpointsTableCreateCompanionBuilder =
    SignalEndpointsCompanion Function({
      Value<int> id,
      required int blockId,
      Value<SignalDestination?> destination,
      Value<SignalSource?> source,
      Value<int?> pairedBlockId,
      Value<String?> gear,
      Value<String?> notes,
    });
typedef $$SignalEndpointsTableUpdateCompanionBuilder =
    SignalEndpointsCompanion Function({
      Value<int> id,
      Value<int> blockId,
      Value<SignalDestination?> destination,
      Value<SignalSource?> source,
      Value<int?> pairedBlockId,
      Value<String?> gear,
      Value<String?> notes,
    });

final class $$SignalEndpointsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SignalEndpointsTable, SignalEndpoint> {
  $$SignalEndpointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SignalBlocksTable _blockIdTable(_$AppDatabase db) => db.signalBlocks
      .createAlias('signal_endpoints__block_id__signal_blocks__id');

  $$SignalBlocksTableProcessedTableManager get blockId {
    final $_column = $_itemColumn<int>('block_id')!;

    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_blockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalBlocksTable _pairedBlockIdTable(_$AppDatabase db) => db
      .signalBlocks
      .createAlias('signal_endpoints__paired_block_id__signal_blocks__id');

  $$SignalBlocksTableProcessedTableManager? get pairedBlockId {
    final $_column = $_itemColumn<int>('paired_block_id');
    if ($_column == null) return null;
    final manager = $$SignalBlocksTableTableManager(
      $_db,
      $_db.signalBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairedBlockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SignalEndpointsTableFilterComposer
    extends Composer<_$AppDatabase, $SignalEndpointsTable> {
  $$SignalEndpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SignalDestination?, SignalDestination, String>
  get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SignalSource?, SignalSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get gear => $composableBuilder(
    column: $table.gear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SignalBlocksTableFilterComposer get blockId {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableFilterComposer get pairedBlockId {
    final $$SignalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairedBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEndpointsTableOrderingComposer
    extends Composer<_$AppDatabase, $SignalEndpointsTable> {
  $$SignalEndpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gear => $composableBuilder(
    column: $table.gear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SignalBlocksTableOrderingComposer get blockId {
    final $$SignalBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableOrderingComposer get pairedBlockId {
    final $$SignalBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairedBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEndpointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignalEndpointsTable> {
  $$SignalEndpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalDestination?, String>
  get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SignalSource?, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get gear =>
      $composableBuilder(column: $table.gear, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SignalBlocksTableAnnotationComposer get blockId {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalBlocksTableAnnotationComposer get pairedBlockId {
    final $$SignalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairedBlockId,
      referencedTable: $db.signalBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.signalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEndpointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SignalEndpointsTable,
          SignalEndpoint,
          $$SignalEndpointsTableFilterComposer,
          $$SignalEndpointsTableOrderingComposer,
          $$SignalEndpointsTableAnnotationComposer,
          $$SignalEndpointsTableCreateCompanionBuilder,
          $$SignalEndpointsTableUpdateCompanionBuilder,
          (SignalEndpoint, $$SignalEndpointsTableReferences),
          SignalEndpoint,
          PrefetchHooks Function({bool blockId, bool pairedBlockId})
        > {
  $$SignalEndpointsTableTableManager(
    _$AppDatabase db,
    $SignalEndpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalEndpointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalEndpointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalEndpointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> blockId = const Value.absent(),
                Value<SignalDestination?> destination = const Value.absent(),
                Value<SignalSource?> source = const Value.absent(),
                Value<int?> pairedBlockId = const Value.absent(),
                Value<String?> gear = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SignalEndpointsCompanion(
                id: id,
                blockId: blockId,
                destination: destination,
                source: source,
                pairedBlockId: pairedBlockId,
                gear: gear,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int blockId,
                Value<SignalDestination?> destination = const Value.absent(),
                Value<SignalSource?> source = const Value.absent(),
                Value<int?> pairedBlockId = const Value.absent(),
                Value<String?> gear = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SignalEndpointsCompanion.insert(
                id: id,
                blockId: blockId,
                destination: destination,
                source: source,
                pairedBlockId: pairedBlockId,
                gear: gear,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SignalEndpointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({blockId = false, pairedBlockId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (blockId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.blockId,
                                referencedTable:
                                    $$SignalEndpointsTableReferences
                                        ._blockIdTable(db),
                                referencedColumn:
                                    $$SignalEndpointsTableReferences
                                        ._blockIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (pairedBlockId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pairedBlockId,
                                referencedTable:
                                    $$SignalEndpointsTableReferences
                                        ._pairedBlockIdTable(db),
                                referencedColumn:
                                    $$SignalEndpointsTableReferences
                                        ._pairedBlockIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SignalEndpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SignalEndpointsTable,
      SignalEndpoint,
      $$SignalEndpointsTableFilterComposer,
      $$SignalEndpointsTableOrderingComposer,
      $$SignalEndpointsTableAnnotationComposer,
      $$SignalEndpointsTableCreateCompanionBuilder,
      $$SignalEndpointsTableUpdateCompanionBuilder,
      (SignalEndpoint, $$SignalEndpointsTableReferences),
      SignalEndpoint,
      PrefetchHooks Function({bool blockId, bool pairedBlockId})
    >;
typedef $$RigSnapshotsTableCreateCompanionBuilder =
    RigSnapshotsCompanion Function({
      Value<int> id,
      required int pedalboardId,
      required String name,
      Value<String?> notes,
      required DateTime capturedAt,
      Value<String?> endpointSummary,
    });
typedef $$RigSnapshotsTableUpdateCompanionBuilder =
    RigSnapshotsCompanion Function({
      Value<int> id,
      Value<int> pedalboardId,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> capturedAt,
      Value<String?> endpointSummary,
    });

final class $$RigSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $RigSnapshotsTable, RigSnapshot> {
  $$RigSnapshotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedalboardsTable _pedalboardIdTable(_$AppDatabase db) => db
      .pedalboards
      .createAlias('rig_snapshots__pedalboard_id__pedalboards__id');

  $$PedalboardsTableProcessedTableManager get pedalboardId {
    final $_column = $_itemColumn<int>('pedalboard_id')!;

    final manager = $$PedalboardsTableTableManager(
      $_db,
      $_db.pedalboards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalboardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RigSnapshotEntriesTable, List<RigSnapshotEntry>>
  _rigSnapshotEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rigSnapshotEntries,
        aliasName: 'rig_snapshots__id__rig_snapshot_entries__snapshot_id',
      );

  $$RigSnapshotEntriesTableProcessedTableManager get rigSnapshotEntriesRefs {
    final manager = $$RigSnapshotEntriesTableTableManager(
      $_db,
      $_db.rigSnapshotEntries,
    ).filter((f) => f.snapshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rigSnapshotEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RigSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $RigSnapshotsTable> {
  $$RigSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpointSummary => $composableBuilder(
    column: $table.endpointSummary,
    builder: (column) => ColumnFilters(column),
  );

  $$PedalboardsTableFilterComposer get pedalboardId {
    final $$PedalboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableFilterComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rigSnapshotEntriesRefs(
    Expression<bool> Function($$RigSnapshotEntriesTableFilterComposer f) f,
  ) {
    final $$RigSnapshotEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rigSnapshotEntries,
      getReferencedColumn: (t) => t.snapshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotEntriesTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshotEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RigSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $RigSnapshotsTable> {
  $$RigSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpointSummary => $composableBuilder(
    column: $table.endpointSummary,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedalboardsTableOrderingComposer get pedalboardId {
    final $$PedalboardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableOrderingComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RigSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RigSnapshotsTable> {
  $$RigSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpointSummary => $composableBuilder(
    column: $table.endpointSummary,
    builder: (column) => column,
  );

  $$PedalboardsTableAnnotationComposer get pedalboardId {
    final $$PedalboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalboardId,
      referencedTable: $db.pedalboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedalboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rigSnapshotEntriesRefs<T extends Object>(
    Expression<T> Function($$RigSnapshotEntriesTableAnnotationComposer a) f,
  ) {
    final $$RigSnapshotEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rigSnapshotEntries,
          getReferencedColumn: (t) => t.snapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RigSnapshotEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.rigSnapshotEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RigSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RigSnapshotsTable,
          RigSnapshot,
          $$RigSnapshotsTableFilterComposer,
          $$RigSnapshotsTableOrderingComposer,
          $$RigSnapshotsTableAnnotationComposer,
          $$RigSnapshotsTableCreateCompanionBuilder,
          $$RigSnapshotsTableUpdateCompanionBuilder,
          (RigSnapshot, $$RigSnapshotsTableReferences),
          RigSnapshot,
          PrefetchHooks Function({
            bool pedalboardId,
            bool rigSnapshotEntriesRefs,
          })
        > {
  $$RigSnapshotsTableTableManager(_$AppDatabase db, $RigSnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RigSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RigSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RigSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pedalboardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> endpointSummary = const Value.absent(),
              }) => RigSnapshotsCompanion(
                id: id,
                pedalboardId: pedalboardId,
                name: name,
                notes: notes,
                capturedAt: capturedAt,
                endpointSummary: endpointSummary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pedalboardId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime capturedAt,
                Value<String?> endpointSummary = const Value.absent(),
              }) => RigSnapshotsCompanion.insert(
                id: id,
                pedalboardId: pedalboardId,
                name: name,
                notes: notes,
                capturedAt: capturedAt,
                endpointSummary: endpointSummary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RigSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({pedalboardId = false, rigSnapshotEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rigSnapshotEntriesRefs) db.rigSnapshotEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pedalboardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalboardId,
                                    referencedTable:
                                        $$RigSnapshotsTableReferences
                                            ._pedalboardIdTable(db),
                                    referencedColumn:
                                        $$RigSnapshotsTableReferences
                                            ._pedalboardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rigSnapshotEntriesRefs)
                        await $_getPrefetchedData<
                          RigSnapshot,
                          $RigSnapshotsTable,
                          RigSnapshotEntry
                        >(
                          currentTable: table,
                          referencedTable: $$RigSnapshotsTableReferences
                              ._rigSnapshotEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RigSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).rigSnapshotEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.snapshotId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RigSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RigSnapshotsTable,
      RigSnapshot,
      $$RigSnapshotsTableFilterComposer,
      $$RigSnapshotsTableOrderingComposer,
      $$RigSnapshotsTableAnnotationComposer,
      $$RigSnapshotsTableCreateCompanionBuilder,
      $$RigSnapshotsTableUpdateCompanionBuilder,
      (RigSnapshot, $$RigSnapshotsTableReferences),
      RigSnapshot,
      PrefetchHooks Function({bool pedalboardId, bool rigSnapshotEntriesRefs})
    >;
typedef $$RigSnapshotEntriesTableCreateCompanionBuilder =
    RigSnapshotEntriesCompanion Function({
      Value<int> id,
      required int snapshotId,
      required int pedalId,
      required int position,
      Value<String?> configurationName,
      Value<bool> isEnabled,
    });
typedef $$RigSnapshotEntriesTableUpdateCompanionBuilder =
    RigSnapshotEntriesCompanion Function({
      Value<int> id,
      Value<int> snapshotId,
      Value<int> pedalId,
      Value<int> position,
      Value<String?> configurationName,
      Value<bool> isEnabled,
    });

final class $$RigSnapshotEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RigSnapshotEntriesTable,
          RigSnapshotEntry
        > {
  $$RigSnapshotEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RigSnapshotsTable _snapshotIdTable(_$AppDatabase db) => db
      .rigSnapshots
      .createAlias('rig_snapshot_entries__snapshot_id__rig_snapshots__id');

  $$RigSnapshotsTableProcessedTableManager get snapshotId {
    final $_column = $_itemColumn<int>('snapshot_id')!;

    final manager = $$RigSnapshotsTableTableManager(
      $_db,
      $_db.rigSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_snapshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PedalsTable _pedalIdTable(_$AppDatabase db) =>
      db.pedals.createAlias('rig_snapshot_entries__pedal_id__pedals__id');

  $$PedalsTableProcessedTableManager get pedalId {
    final $_column = $_itemColumn<int>('pedal_id')!;

    final manager = $$PedalsTableTableManager(
      $_db,
      $_db.pedals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RigSnapshotValuesTable, List<RigSnapshotValue>>
  _rigSnapshotValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rigSnapshotValues,
        aliasName: 'rig_snapshot_entries__id__rig_snapshot_values__entry_id',
      );

  $$RigSnapshotValuesTableProcessedTableManager get rigSnapshotValuesRefs {
    final manager = $$RigSnapshotValuesTableTableManager(
      $_db,
      $_db.rigSnapshotValues,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rigSnapshotValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RigSnapshotEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RigSnapshotEntriesTable> {
  $$RigSnapshotEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  $$RigSnapshotsTableFilterComposer get snapshotId {
    final $$RigSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.rigSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableFilterComposer get pedalId {
    final $$PedalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableFilterComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rigSnapshotValuesRefs(
    Expression<bool> Function($$RigSnapshotValuesTableFilterComposer f) f,
  ) {
    final $$RigSnapshotValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rigSnapshotValues,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotValuesTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshotValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RigSnapshotEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RigSnapshotEntriesTable> {
  $$RigSnapshotEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$RigSnapshotsTableOrderingComposer get snapshotId {
    final $$RigSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.rigSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.rigSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableOrderingComposer get pedalId {
    final $$PedalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableOrderingComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RigSnapshotEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RigSnapshotEntriesTable> {
  $$RigSnapshotEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get configurationName => $composableBuilder(
    column: $table.configurationName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  $$RigSnapshotsTableAnnotationComposer get snapshotId {
    final $$RigSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.rigSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.rigSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PedalsTableAnnotationComposer get pedalId {
    final $$PedalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedalId,
      referencedTable: $db.pedals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedalsTableAnnotationComposer(
            $db: $db,
            $table: $db.pedals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rigSnapshotValuesRefs<T extends Object>(
    Expression<T> Function($$RigSnapshotValuesTableAnnotationComposer a) f,
  ) {
    final $$RigSnapshotValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rigSnapshotValues,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RigSnapshotValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.rigSnapshotValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RigSnapshotEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RigSnapshotEntriesTable,
          RigSnapshotEntry,
          $$RigSnapshotEntriesTableFilterComposer,
          $$RigSnapshotEntriesTableOrderingComposer,
          $$RigSnapshotEntriesTableAnnotationComposer,
          $$RigSnapshotEntriesTableCreateCompanionBuilder,
          $$RigSnapshotEntriesTableUpdateCompanionBuilder,
          (RigSnapshotEntry, $$RigSnapshotEntriesTableReferences),
          RigSnapshotEntry,
          PrefetchHooks Function({
            bool snapshotId,
            bool pedalId,
            bool rigSnapshotValuesRefs,
          })
        > {
  $$RigSnapshotEntriesTableTableManager(
    _$AppDatabase db,
    $RigSnapshotEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RigSnapshotEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RigSnapshotEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RigSnapshotEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> snapshotId = const Value.absent(),
                Value<int> pedalId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> configurationName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
              }) => RigSnapshotEntriesCompanion(
                id: id,
                snapshotId: snapshotId,
                pedalId: pedalId,
                position: position,
                configurationName: configurationName,
                isEnabled: isEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int snapshotId,
                required int pedalId,
                required int position,
                Value<String?> configurationName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
              }) => RigSnapshotEntriesCompanion.insert(
                id: id,
                snapshotId: snapshotId,
                pedalId: pedalId,
                position: position,
                configurationName: configurationName,
                isEnabled: isEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RigSnapshotEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                snapshotId = false,
                pedalId = false,
                rigSnapshotValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rigSnapshotValuesRefs) db.rigSnapshotValues,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (snapshotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.snapshotId,
                                    referencedTable:
                                        $$RigSnapshotEntriesTableReferences
                                            ._snapshotIdTable(db),
                                    referencedColumn:
                                        $$RigSnapshotEntriesTableReferences
                                            ._snapshotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (pedalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pedalId,
                                    referencedTable:
                                        $$RigSnapshotEntriesTableReferences
                                            ._pedalIdTable(db),
                                    referencedColumn:
                                        $$RigSnapshotEntriesTableReferences
                                            ._pedalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rigSnapshotValuesRefs)
                        await $_getPrefetchedData<
                          RigSnapshotEntry,
                          $RigSnapshotEntriesTable,
                          RigSnapshotValue
                        >(
                          currentTable: table,
                          referencedTable: $$RigSnapshotEntriesTableReferences
                              ._rigSnapshotValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RigSnapshotEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).rigSnapshotValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RigSnapshotEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RigSnapshotEntriesTable,
      RigSnapshotEntry,
      $$RigSnapshotEntriesTableFilterComposer,
      $$RigSnapshotEntriesTableOrderingComposer,
      $$RigSnapshotEntriesTableAnnotationComposer,
      $$RigSnapshotEntriesTableCreateCompanionBuilder,
      $$RigSnapshotEntriesTableUpdateCompanionBuilder,
      (RigSnapshotEntry, $$RigSnapshotEntriesTableReferences),
      RigSnapshotEntry,
      PrefetchHooks Function({
        bool snapshotId,
        bool pedalId,
        bool rigSnapshotValuesRefs,
      })
    >;
typedef $$RigSnapshotValuesTableCreateCompanionBuilder =
    RigSnapshotValuesCompanion Function({
      Value<int> id,
      required int entryId,
      required String controlName,
      Value<String?> controlPedalName,
      required ControlType controlType,
      required double value,
      Value<String?> unit,
      Value<String?> options,
      required int displayOrder,
    });
typedef $$RigSnapshotValuesTableUpdateCompanionBuilder =
    RigSnapshotValuesCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> controlName,
      Value<String?> controlPedalName,
      Value<ControlType> controlType,
      Value<double> value,
      Value<String?> unit,
      Value<String?> options,
      Value<int> displayOrder,
    });

final class $$RigSnapshotValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RigSnapshotValuesTable,
          RigSnapshotValue
        > {
  $$RigSnapshotValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RigSnapshotEntriesTable _entryIdTable(_$AppDatabase db) => db
      .rigSnapshotEntries
      .createAlias('rig_snapshot_values__entry_id__rig_snapshot_entries__id');

  $$RigSnapshotEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$RigSnapshotEntriesTableTableManager(
      $_db,
      $_db.rigSnapshotEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RigSnapshotValuesTableFilterComposer
    extends Composer<_$AppDatabase, $RigSnapshotValuesTable> {
  $$RigSnapshotValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ControlType, ControlType, String>
  get controlType => $composableBuilder(
    column: $table.controlType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$RigSnapshotEntriesTableFilterComposer get entryId {
    final $$RigSnapshotEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.rigSnapshotEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotEntriesTableFilterComposer(
            $db: $db,
            $table: $db.rigSnapshotEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RigSnapshotValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $RigSnapshotValuesTable> {
  $$RigSnapshotValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlType => $composableBuilder(
    column: $table.controlType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$RigSnapshotEntriesTableOrderingComposer get entryId {
    final $$RigSnapshotEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.rigSnapshotEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RigSnapshotEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.rigSnapshotEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RigSnapshotValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RigSnapshotValuesTable> {
  $$RigSnapshotValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get controlName => $composableBuilder(
    column: $table.controlName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get controlPedalName => $composableBuilder(
    column: $table.controlPedalName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ControlType, String> get controlType =>
      $composableBuilder(
        column: $table.controlType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  $$RigSnapshotEntriesTableAnnotationComposer get entryId {
    final $$RigSnapshotEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.entryId,
          referencedTable: $db.rigSnapshotEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RigSnapshotEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.rigSnapshotEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RigSnapshotValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RigSnapshotValuesTable,
          RigSnapshotValue,
          $$RigSnapshotValuesTableFilterComposer,
          $$RigSnapshotValuesTableOrderingComposer,
          $$RigSnapshotValuesTableAnnotationComposer,
          $$RigSnapshotValuesTableCreateCompanionBuilder,
          $$RigSnapshotValuesTableUpdateCompanionBuilder,
          (RigSnapshotValue, $$RigSnapshotValuesTableReferences),
          RigSnapshotValue,
          PrefetchHooks Function({bool entryId})
        > {
  $$RigSnapshotValuesTableTableManager(
    _$AppDatabase db,
    $RigSnapshotValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RigSnapshotValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RigSnapshotValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RigSnapshotValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> controlName = const Value.absent(),
                Value<String?> controlPedalName = const Value.absent(),
                Value<ControlType> controlType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> options = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => RigSnapshotValuesCompanion(
                id: id,
                entryId: entryId,
                controlName: controlName,
                controlPedalName: controlPedalName,
                controlType: controlType,
                value: value,
                unit: unit,
                options: options,
                displayOrder: displayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String controlName,
                Value<String?> controlPedalName = const Value.absent(),
                required ControlType controlType,
                required double value,
                Value<String?> unit = const Value.absent(),
                Value<String?> options = const Value.absent(),
                required int displayOrder,
              }) => RigSnapshotValuesCompanion.insert(
                id: id,
                entryId: entryId,
                controlName: controlName,
                controlPedalName: controlPedalName,
                controlType: controlType,
                value: value,
                unit: unit,
                options: options,
                displayOrder: displayOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RigSnapshotValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable:
                                    $$RigSnapshotValuesTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$RigSnapshotValuesTableReferences
                                        ._entryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RigSnapshotValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RigSnapshotValuesTable,
      RigSnapshotValue,
      $$RigSnapshotValuesTableFilterComposer,
      $$RigSnapshotValuesTableOrderingComposer,
      $$RigSnapshotValuesTableAnnotationComposer,
      $$RigSnapshotValuesTableCreateCompanionBuilder,
      $$RigSnapshotValuesTableUpdateCompanionBuilder,
      (RigSnapshotValue, $$RigSnapshotValuesTableReferences),
      RigSnapshotValue,
      PrefetchHooks Function({bool entryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db, _db.pedals);
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db, _db.pedalControls);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(_db, _db.configurations);
  $$ConfigurationValuesTableTableManager get configurationValues =>
      $$ConfigurationValuesTableTableManager(_db, _db.configurationValues);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db, _db.patches);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db, _db.scenes);
  $$ScenePedalsTableTableManager get scenePedals =>
      $$ScenePedalsTableTableManager(_db, _db.scenePedals);
  $$SceneValuesTableTableManager get sceneValues =>
      $$SceneValuesTableTableManager(_db, _db.sceneValues);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db, _db.changeLogs);
  $$PedalReplacementsTableTableManager get pedalReplacements =>
      $$PedalReplacementsTableTableManager(_db, _db.pedalReplacements);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db, _db.pedalboards);
  $$SignalBlocksTableTableManager get signalBlocks =>
      $$SignalBlocksTableTableManager(_db, _db.signalBlocks);
  $$SignalConnectionsTableTableManager get signalConnections =>
      $$SignalConnectionsTableTableManager(_db, _db.signalConnections);
  $$SignalEndpointsTableTableManager get signalEndpoints =>
      $$SignalEndpointsTableTableManager(_db, _db.signalEndpoints);
  $$RigSnapshotsTableTableManager get rigSnapshots =>
      $$RigSnapshotsTableTableManager(_db, _db.rigSnapshots);
  $$RigSnapshotEntriesTableTableManager get rigSnapshotEntries =>
      $$RigSnapshotEntriesTableTableManager(_db, _db.rigSnapshotEntries);
  $$RigSnapshotValuesTableTableManager get rigSnapshotValues =>
      $$RigSnapshotValuesTableTableManager(_db, _db.rigSnapshotValues);
}
