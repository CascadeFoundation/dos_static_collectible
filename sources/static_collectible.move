module dos_static_collectible::static_collectible;

use cascade_protocol::mint_cap::MintCap;
use std::string::String;
use sui::hash::blake2b256;
use sui::hex;
use sui::vec_map::{Self, VecMap};

public struct StaticCollectible has store {
    number: u64,
    name: String,
    description: String,
    external_url: String,
    reveal_state: RevealState,
}

public enum RevealState has copy, drop, store {
    UNREVEALED {
        provenance_hash: String,
    },
    REVEALED {
        attributes: VecMap<String, String>,
        image_uri: String,
    },
}

const EAttributesLengthMismatch: u64 = 0;
const EIncorrectProvenanceHash: u64 = 1;
const ECollectibleAlreadyRevealed: u64 = 2;
const ECollectibleNotRevealed: u64 = 3;

// Create a new static StaticCollectible.
//
// The `image_uri` is specified upfront because it can be calculated ahead of time
// without revealing the image. For example, if you're using Walrus for image storage,
// you can use the Walrus CLI to pre-calculate blob IDs to use as image URIs.
// The actual image can be uploaded at a later time.
public fun new(
    cap: MintCap<StaticCollectible>,
    name: String,
    number: u64,
    description: String,
    external_url: String,
    provenance_hash: String,
): StaticCollectible {
    cap.destroy();

    StaticCollectible {
        number: number,
        name: name,
        description: description,
        external_url: external_url,
        reveal_state: RevealState::UNREVEALED { provenance_hash: provenance_hash },
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
    image_uri: String,
) {
    match (self.reveal_state) {
        RevealState::UNREVEALED { provenance_hash } => {
            // Verify the attribute keys and values vectors are the same size.
            assert!(
                attribute_keys.length() == attribute_values.length(),
                EAttributesLengthMismatch,
            );
            // Calculate the provenance hash onchain with the StaticCollectible's number,
            // and the provided attributes and image URI.
            let calculated_provenance_hash = calculate_provenance_hash(
                self.number,
                attribute_keys,
                attribute_values,
                image_uri,
            );
            // Assert the calculated provenance hash matches the initial provenance hash.
            assert!(calculated_provenance_hash == provenance_hash, EIncorrectProvenanceHash);
            // Set the StaticCollectible's state to REVEALED.
            self.reveal_state =
                RevealState::REVEALED {
                    attributes: vec_map::from_keys_values(attribute_keys, attribute_values),
                    image_uri: image_uri,
                }
        },
        RevealState::REVEALED { .. } => abort ECollectibleAlreadyRevealed,
    }
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

public fun external_url(self: &StaticCollectible): String {
    self.external_url
}

public fun attributes(self: &StaticCollectible): VecMap<String, String> {
    match (self.reveal_state) {
        RevealState::REVEALED { attributes, .. } => attributes,
        _ => abort ECollectibleNotRevealed,
    }
}

public fun image_uri(self: &StaticCollectible): String {
    match (self.reveal_state) {
        RevealState::REVEALED { image_uri, .. } => image_uri,
        _ => abort ECollectibleNotRevealed,
    }
}

public fun provenance_hash(self: &StaticCollectible): String {
    match (self.reveal_state) {
        RevealState::UNREVEALED { provenance_hash } => provenance_hash,
        _ => abort ECollectibleAlreadyRevealed,
    }
}

//=== Package Functions ===

public(package) fun calculate_provenance_hash(
    number: u64,
    attribute_keys: vector<String>,
    attribute_values: vector<String>,
    image_uri: String,
): String {
    // Initialize input string for hashing.
    let mut input = b"".to_string();
    input.append(number.to_string());

    // Concatenate the attribute keys and values.
    attribute_keys.do!(|v| input.append(v));
    attribute_values.do!(|v| input.append(v));

    // Concatenate the image URI.
    input.append(image_uri);

    // Calculate the hash, and return hex string representation.
    hex::encode(blake2b256(input.as_bytes())).to_string()
}

#[test]
fun test_calculate_provenance_hash() {
    let number = 100;
    let attribute_keys: vector<String> = vector[
        b"aura".to_string(),
        b"background".to_string(),
        b"clothing".to_string(),
        b"decal".to_string(),
        b"headwear".to_string(),
        b"highlight".to_string(),
        b"internals".to_string(),
        b"mask".to_string(),
        b"screen".to_string(),
        b"skin".to_string(),
    ];
    let attribute_values: vector<String> = vector[
        b"none".to_string(),
        b"green".to_string(),
        b"none".to_string(),
        b"none".to_string(),
        b"classic-antenna".to_string(),
        b"green".to_string(),
        b"gray".to_string(),
        b"hyottoko".to_string(),
        b"tamashi-eyes".to_string(),
        b"silver".to_string(),
    ];
    let image_uri = b"MvcX8hU5esyvO1M8NRCrleSQjS9YaH57YBedKIUpYn8".to_string();
    let provenance_hash = calculate_provenance_hash(
        number,
        attribute_keys,
        attribute_values,
        image_uri,
    );
    std::debug::print(&provenance_hash);
}
