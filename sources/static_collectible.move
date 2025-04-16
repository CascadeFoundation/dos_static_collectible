module dos_static_collectible::static_collectible;

use std::string::String;
use std::type_name::TypeName;
use sui::event::emit;
use sui::vec_map::{Self, VecMap};

//=== Structs ===

public struct StaticCollectible has store {
    number: u64,
    name: String,
    description: String,
    parent_type: TypeName,
    attributes: VecMap<String, String>,
    image: String,
    animation_url: String,
    external_url: String,
}

//=== Events ===

public struct StaticCollectibleCreatedEvent has copy, drop {
    parent_type: TypeName,
    collectible_number: u64,
}

public struct StaticCollectibleDestroyedEvent has copy, drop {
    parent_type: TypeName,
    collectible_number: u64,
}

public struct StaticCollectibleRevealedEvent has copy, drop {
    parent_type: TypeName,
    collectible_number: u64,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
}

//=== Constants ===

const EAttributesLengthMismatch: u64 = 10000;

//=== Public Functions ===

// Create a new static StaticCollectible.
//
// The `image` is specified upfront because it can be calculated ahead of time
// without revealing the image. For example, if you're using Walrus for image storage,
// you can use the Walrus CLI to pre-calculate blob IDs to use as image URIs.
// The actual image can be uploaded to Walrus at a later time.
public fun new(
    name: String,
    number: u64,
    description: String,
    image: String,
    animation_url: String,
    external_url: String,
    parent_type: TypeName,
): StaticCollectible {
    let collectible = StaticCollectible {
        number: number,
        name: name,
        description: description,
        parent_type: parent_type,
        image: image,
        animation_url: animation_url,
        external_url: external_url,
        attributes: vec_map::empty(),
    };

    emit(StaticCollectibleCreatedEvent {
        parent_type: collectible.parent_type,
        collectible_number: collectible.number,
    });

    collectible
}

public fun destroy(self: StaticCollectible) {
    let StaticCollectible {
        parent_type,
        number,
        ..,
    } = self;

    emit(StaticCollectibleDestroyedEvent {
        parent_type: parent_type,
        collectible_number: number,
    });
}

public fun reveal(
    self: &mut StaticCollectible,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
) {
    assert!(attribute_keys.length() == attribute_values.length(), EAttributesLengthMismatch);

    emit(StaticCollectibleRevealedEvent {
        parent_type: self.parent_type,
        collectible_number: self.number,
        attribute_keys: attribute_keys,
        attribute_values: attribute_values,
    });

    self.attributes = vec_map::from_keys_values(attribute_keys, attribute_values);
}

public fun name(self: &StaticCollectible): String {
    self.name
}

public fun number(self: &StaticCollectible): u64 {
    self.number
}

public fun description(self: &StaticCollectible): String {
    self.description
}

public fun image(self: &StaticCollectible): String {
    self.image
}

public fun animation_url(self: &StaticCollectible): String {
    self.animation_url
}

public fun external_url(self: &StaticCollectible): String {
    self.external_url
}

public fun attributes(self: &StaticCollectible): VecMap<String, String> {
    self.attributes
}

public fun parent_type(self: &StaticCollectible): TypeName {
    self.parent_type
}
