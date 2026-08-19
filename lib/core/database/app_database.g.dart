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
}

class Pedal extends DataClass implements Insertable<Pedal> {
  final int id;
  final String name;
  final String? brand;
  final PedalType type;
  final PedalCategory category;
  final PedalStatus status;

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
    changeType,
    oldValue,
    newValue,
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
  final ChangeType changeType;

  /// Set only for events that move a control, in that control's own domain.
  final double? oldValue;
  final double? newValue;

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
    required this.changeType,
    this.oldValue,
    this.newValue,
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
      changeType: Value(changeType),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
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
      changeType: $ChangeLogsTable.$converterchangeType.fromJson(
        serializer.fromJson<String>(json['changeType']),
      ),
      oldValue: serializer.fromJson<double?>(json['oldValue']),
      newValue: serializer.fromJson<double?>(json['newValue']),
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
      'changeType': serializer.toJson<String>(
        $ChangeLogsTable.$converterchangeType.toJson(changeType),
      ),
      'oldValue': serializer.toJson<double?>(oldValue),
      'newValue': serializer.toJson<double?>(newValue),
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
    ChangeType? changeType,
    Value<double?> oldValue = const Value.absent(),
    Value<double?> newValue = const Value.absent(),
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
    changeType: changeType ?? this.changeType,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
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
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
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
          ..write('changeType: $changeType, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
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
    changeType,
    oldValue,
    newValue,
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
          other.changeType == this.changeType &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
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
  final Value<ChangeType> changeType;
  final Value<double?> oldValue;
  final Value<double?> newValue;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  const ChangeLogsCompanion({
    this.id = const Value.absent(),
    this.pedalId = const Value.absent(),
    this.configurationId = const Value.absent(),
    this.controlId = const Value.absent(),
    this.configurationName = const Value.absent(),
    this.controlName = const Value.absent(),
    this.changeType = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
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
    required ChangeType changeType,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
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
    Expression<String>? changeType,
    Expression<double>? oldValue,
    Expression<double>? newValue,
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
      if (changeType != null) 'change_type': changeType,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
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
    Value<ChangeType>? changeType,
    Value<double?>? oldValue,
    Value<double?>? newValue,
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
      changeType: changeType ?? this.changeType,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
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
          ..write('changeType: $changeType, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PedalsTable pedals = $PedalsTable(this);
  late final $PedalControlsTable pedalControls = $PedalControlsTable(this);
  late final $ConfigurationsTable configurations = $ConfigurationsTable(this);
  late final $ConfigurationValuesTable configurationValues =
      $ConfigurationValuesTable(this);
  late final $ChangeLogsTable changeLogs = $ChangeLogsTable(this);
  late final $PedalReplacementsTable pedalReplacements =
      $PedalReplacementsTable(this);
  late final $PedalboardsTable pedalboards = $PedalboardsTable(this);
  late final Index idxPedalsStatus = Index(
    'idx_pedals_status',
    'CREATE INDEX idx_pedals_status ON pedals (status)',
  );
  late final Index idxPedalsName = Index(
    'idx_pedals_name',
    'CREATE INDEX idx_pedals_name ON pedals (name)',
  );
  late final Index idxPedalControlsPedalOrder = Index(
    'idx_pedal_controls_pedal_order',
    'CREATE INDEX idx_pedal_controls_pedal_order ON pedal_controls (pedal_id, display_order)',
  );
  late final Index idxConfigurationsPedal = Index(
    'idx_configurations_pedal',
    'CREATE INDEX idx_configurations_pedal ON configurations (pedal_id)',
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
  late final PedalDao pedalDao = PedalDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pedals,
    pedalControls,
    configurations,
    configurationValues,
    changeLogs,
    pedalReplacements,
    pedalboards,
    idxPedalsStatus,
    idxPedalsName,
    idxPedalControlsPedalOrder,
    idxConfigurationsPedal,
    idxChangeLogsPedalTime,
    idxChangeLogsConfiguration,
    idxPedalReplacementsOld,
    idxPedalReplacementsNew,
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
      Value<String?> photoPath,
      Value<DateTime?> purchaseDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PedalsTableReferences
    extends BaseReferences<_$AppDatabase, $PedalsTable, Pedal> {
  $$PedalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

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
            bool pedalControlsRefs,
            bool configurationsRefs,
            bool changeLogsRefs,
            bool replacementsWhereOutgoing,
            bool replacementsWhereIncoming,
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
                pedalControlsRefs = false,
                configurationsRefs = false,
                changeLogsRefs = false,
                replacementsWhereOutgoing = false,
                replacementsWhereIncoming = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pedalControlsRefs) db.pedalControls,
                    if (configurationsRefs) db.configurations,
                    if (changeLogsRefs) db.changeLogs,
                    if (replacementsWhereOutgoing) db.pedalReplacements,
                    if (replacementsWhereIncoming) db.pedalReplacements,
                  ],
                  addJoins: null,
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
        bool pedalControlsRefs,
        bool configurationsRefs,
        bool changeLogsRefs,
        bool replacementsWhereOutgoing,
        bool replacementsWhereIncoming,
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
typedef $$ChangeLogsTableCreateCompanionBuilder =
    ChangeLogsCompanion Function({
      Value<int> id,
      required int pedalId,
      Value<int?> configurationId,
      Value<int?> controlId,
      Value<String?> configurationName,
      Value<String?> controlName,
      required ChangeType changeType,
      Value<double?> oldValue,
      Value<double?> newValue,
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
      Value<ChangeType> changeType,
      Value<double?> oldValue,
      Value<double?> newValue,
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

  GeneratedColumnWithTypeConverter<ChangeType, String> get changeType =>
      $composableBuilder(
        column: $table.changeType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<double> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

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
                Value<ChangeType> changeType = const Value.absent(),
                Value<double?> oldValue = const Value.absent(),
                Value<double?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChangeLogsCompanion(
                id: id,
                pedalId: pedalId,
                configurationId: configurationId,
                controlId: controlId,
                configurationName: configurationName,
                controlName: controlName,
                changeType: changeType,
                oldValue: oldValue,
                newValue: newValue,
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
                required ChangeType changeType,
                Value<double?> oldValue = const Value.absent(),
                Value<double?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
              }) => ChangeLogsCompanion.insert(
                id: id,
                pedalId: pedalId,
                configurationId: configurationId,
                controlId: controlId,
                configurationName: configurationName,
                controlName: controlName,
                changeType: changeType,
                oldValue: oldValue,
                newValue: newValue,
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
          (
            Pedalboard,
            BaseReferences<_$AppDatabase, $PedalboardsTable, Pedalboard>,
          ),
          Pedalboard,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        Pedalboard,
        BaseReferences<_$AppDatabase, $PedalboardsTable, Pedalboard>,
      ),
      Pedalboard,
      PrefetchHooks Function()
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
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db, _db.changeLogs);
  $$PedalReplacementsTableTableManager get pedalReplacements =>
      $$PedalReplacementsTableTableManager(_db, _db.pedalReplacements);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db, _db.pedalboards);
}
