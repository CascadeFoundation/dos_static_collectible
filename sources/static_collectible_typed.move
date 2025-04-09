module dos_static_collectible::static_collectible_typed;

use cascade_protocol::mint_cap::MintCap;
use std::string::String;
use sui::dynamic_field as df;
use sui::hash::blake2b256;
use sui::hex;
use sui::package::{Self, Publisher};
use sui::transfer::Receiving;
use sui::vec_map::{Self, VecMap};

public struct Collectible<phantom COLLECTIBLE> has key, store {
    id: UID,
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

const EInvalidPublisher: u64 = 0;

public fun new<COLLECTIBLE>(
    cap: MintCap<Collectible<COLLECTIBLE>>,
    name: String,
    number: u64,
    description: String,
    external_url: String,
    provenance_hash: String,
    ctx: &mut TxContext,
): Collectible<COLLECTIBLE> {
    cap.destroy();

    Collectible {
        id: object::new(ctx),
        number: number,
        name: name,
        description: description,
        external_url: external_url,
        reveal_state: RevealState::UNREVEALED { provenance_hash: provenance_hash },
    }
}

// Receive an object that's been sent to the collectible.
public fun receive<COLLECTIBLE, OBJECT: key + store>(
    self: &mut Collectible<COLLECTIBLE>,
    obj_to_receive: Receiving<OBJECT>,
): OBJECT {
    transfer::public_receive(&mut self.id, obj_to_receive)
}

// Add a dynamic field to the collectible.
// Requires a Publisher object, which shows control over the collectible's subtype.
public fun add_df<COLLECTIBLE, NAME: copy + drop + store, VALUE: store>(
    self: &mut Collectible<COLLECTIBLE>,
    publisher: &Publisher,
    name: NAME,
    value: VALUE,
) {
    assert!(publisher.from_module<COLLECTIBLE>(), EInvalidPublisher);
    df::add<NAME, VALUE>(&mut self.id, name, value);
}

// Borrow a dynamic field from the collectible.
public fun borrow_df<COLLECTIBLE, NAME: copy + drop + store, VALUE: store>(
    self: &mut Collectible<COLLECTIBLE>,
    name: NAME,
): &VALUE {
    df::borrow<NAME, VALUE>(&self.id, name)
}

// Borrow a mutable dynamic field from the collectible.
// Requires a Publisher object, which shows control over the collectible's subtype.
public fun borrow_mut_df<COLLECTIBLE, NAME: copy + drop + store, VALUE: store>(
    self: &mut Collectible<COLLECTIBLE>,
    publisher: &Publisher,
    name: NAME,
): &mut VALUE {
    assert!(publisher.from_module<COLLECTIBLE>(), EInvalidPublisher);
    df::borrow_mut<NAME, VALUE>(&mut self.id, name)
}

// Remove a dynamic field from the collectible.
// Requires a Publisher object, which shows control over the collectible's subtype.
public fun remove_df<COLLECTIBLE, NAME: copy + drop + store, VALUE: store>(
    self: &mut Collectible<COLLECTIBLE>,
    publisher: &Publisher,
    name: NAME,
): VALUE {
    assert!(publisher.from_module<COLLECTIBLE>(), EInvalidPublisher);
    df::remove<NAME, VALUE>(&mut self.id, name)
}
