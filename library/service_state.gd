class_name ServiceState
extends ActorState


enum {
    NO_SERVICE,
    CART,
    ORDER,
    STICK,
}

const SERVICE_TYPE_TO_TAG: Dictionary = {
    NO_SERVICE: VisualTag.DEFAULT,
    CART: VisualTag.ACTIVE_1,
    ORDER: VisualTag.ACTIVE_2,
    STICK: VisualTag.ACTIVE_3,
}


var service_type: int = NO_SERVICE:
    set(value):
        if SERVICE_TYPE_TO_TAG.has(value):
            service_type = value
            VisualEffect.switch_sprite(_sprite, SERVICE_TYPE_TO_TAG[value])
        else:
            push_error("Invalid service type: %s" % value)


var service_record: Dictionary = {
    CART: false,
    ORDER: false,
    STICK: false,
}


var service_counter: int:
    get:
        var counter: int = 0

        for i in service_record.values():
            if i:
                counter += 1
        return counter
