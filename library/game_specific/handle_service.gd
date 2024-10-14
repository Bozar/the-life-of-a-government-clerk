class_name HandleService


# Update Service state when:
#   PC has unloaded a Document.
#   PC has unloaded a raw file and has used at most 1 Service.
static func set_service_type(states: Array, reset_type: bool,
        ref_RandomNumber: RandomNumber) -> void:

    var state: ServiceState

    for i in states:
        state = i

        if reset_type:
            _reset_service(state)
            _set_new_service(state, ref_RandomNumber)
        elif state.service_counter < GameData.MAX_SERVICE:
            _set_new_service(state, ref_RandomNumber)


static func use_service(state: ServiceState) -> void:
    state.service_record[state.service_type] = true
    state.service_type = ServiceState.NO_SERVICE


static func _reset_service(state: ServiceState) -> void:
    state.service_type = ServiceState.NO_SERVICE
    for i in state.service_record.keys():
        state.service_record[i] = false


static func _set_new_service(state: ServiceState,
        ref_RandomNumber: RandomNumber) -> void:

    var service_types: Array = []
    var new_index: int

    for i in state.service_record.keys():
        if not state.service_record[i]:
            service_types.push_back(i)
    if service_types.is_empty():
        push_warning("No service type available.")
        state.service_type = ServiceState.NO_SERVICE
        return

    new_index = ref_RandomNumber.get_int(0, service_types.size())
    state.service_type = service_types[new_index]
