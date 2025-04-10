module dos_static_collectible::static_collectible;

use cascade_protocol::mint_cap::MintCap;
use std::string::String;
use sui::vec_map::{Self, VecMap};

public struct StaticCollectible has store {
    number: u64,
    name: String,
    description: String,
    attributes: VecMap<String, String>,
    image: String,
    animation_url: String,
    external_url: String,
}

const EAttributesLengthMismatch: u64 = 10000;

// Create a new static StaticCollectible.
//
// The `image` is specified upfront because it can be calculated ahead of time
// without revealing the image. For example, if you're using Walrus for image storage,
// you can use the Walrus CLI to pre-calculate blob IDs to use as image URIs.
// The actual image can be uploaded to Walrus at a later time.
public fun new(
    cap: MintCap<StaticCollectible>,
    name: String,
    number: u64,
    description: String,
    image: String,
    animation_url: String,
    external_url: String,
): StaticCollectible {
    cap.destroy();

    StaticCollectible {
        number: number,
        name: name,
        description: description,
        image: image,
        animation_url: animation_url,
        external_url: external_url,
        attributes: vec_map::empty(),
    }
}

public fun destroy(self: StaticCollectible) {
    let StaticCollectible {
        ..,
    } = self;
}

public fun reveal(
    self: &mut StaticCollectible,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
) {
    assert!(attribute_keys.length() == attribute_values.length(), EAttributesLengthMismatch);
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
