class InterfaceWrapper {
    __New(ptr := "") {
        this.wrapped := ""

        if ptr {
            this.Ptr := ptr
        }
    }

    Ptr {
        get => this.wrapped ? this.wrapped.Ptr : 0
        set {
            if !value {
                return
            }

            interfaces := %this.__Class%.Interfaces
            lastErr := ""
            for i, t in interfaces {
                v := t()
                try {
                    ;; v takes ownership of the pointer.
                    v.Ptr := value

                    ;; But only if its Ptr setter didn't return early.
                    if v.Ptr {
                        this.wrapped := v
                        return
                    }
                } catch as err {
                    ;; If it failed, we have to make sure we don't lose the
                    ;; pointer after v is freed.
                    if v.Ptr {
                        ObjAddRef(value)
                    }
                    lastErr := err.Message
                }
            }

            if lastErr {
                msg := "None of these interfaces seem to be supported:`n"
                for t in interfaces {
                    msg .= "`t" t.Prototype.__Class " (" t.GUID ")`n"
                }
                msg .= "`nLast error: " lastErr
                throw msg
            }
        }
    }
}
