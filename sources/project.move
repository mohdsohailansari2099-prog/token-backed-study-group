module MyModule::TokenBackedStudyGroup {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a token-backed study group
    struct StudyGroup has store, key {
        total_pool: u64,        // Total tokens in the reward pool
        member_count: u64,      // Number of active members
        entry_fee: u64,         // Token amount required to join
    }

    /// Struct to track individual member contributions
    struct MemberRecord has store, key {
        tokens_contributed: u64, // Total tokens contributed by member
        is_active: bool,        // Whether member is still active
    }

    /// Function to create a new study group with entry requirements
    public fun create_study_group(creator: &signer, entry_fee: u64) {
        let study_group = StudyGroup {
            total_pool: 0,
            member_count: 0,
            entry_fee,
        };
        move_to(creator, study_group);
    }

    /// Function for users to join the study group by contributing tokens
    public fun join_study_group(
        member: &signer, 
        group_creator: address
    ) acquires StudyGroup {
        let member_address = signer::address_of(member);
        let study_group = borrow_global_mut<StudyGroup>(group_creator);
        
        // Transfer entry fee from member to group creator
        let contribution = coin::withdraw<AptosCoin>(member, study_group.entry_fee);
        coin::deposit<AptosCoin>(group_creator, contribution);
        
        // Update group statistics
        study_group.total_pool = study_group.total_pool + study_group.entry_fee;
        study_group.member_count = study_group.member_count + 1;
        
        // Create member record
        let member_record = MemberRecord {
            tokens_contributed: study_group.entry_fee,
            is_active: true,
        };
        move_to(member, member_record);
    }
}