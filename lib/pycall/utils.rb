module PyCall
  module Utils
    def append_sys_path(path_str)
      pyobj = LibPython.PyUnicode_DecodeUTF8(path_str, path_str.bytesize, nil)
      sys.path << pyobj
    end

    def callable?(pyobj)
      unless pyobj.kind_of? LibPython::PyObjectStruct
        raise TypeError, "the argument must be a Python object" unless pyobj.respond_to? :__pyobj__
        pyobj = pyobj.__pyobj__
      end
      1 == LibPython.PyCallable_Check(pyobj)
    end

    def dir(pyobj)
      pyobj = pyobj.__pyobj__ unless pyobj.kind_of? LibPython::PyObjectStruct
      value = LibPython.PyObject_Dir(pyobj)
      return value.to_ruby unless value.null?
      raise PyError.fetch
    end

    def incref(pyobj)
      LibPython.Py_IncRef(pyobj)
      pyobj
    end

    def decref(pyobj)
      LibPython.Py_DecRef(pyobj)
      pyobj.send :pointer=, FFI::Pointer::NULL
      pyobj
    end

    def int(pyobj)
      @int ||= PyCall.eval('int')
      @int.(pyobj)
    end

    def len(pyobj)
      @len ||= PyCall.eval('len')
      @len.(pyobj)
    end

    def None
      LibPython.Py_None
    end

    def none?(pyobj)
      case pyobj
      when FFI::Pointer
        address = pyobj.address
      when LibPython::PyPtr
        address = pyobj.__address__
      else
        address = pyobj.__pyobj__.__address__
      end
      # FIXME: Do not use PyPtr.none to avoid extra object allocation
      LibPython::PyPtr.none.__address__ == address
    end

    def slice(*args)
      Slice.new(*args)
    end

    def str(pyobj)
      @str ||= PyCall.eval('str')
      @str.(pyobj)
    end

    def sys
      @sys ||= PyCall.import_module('sys')
    end

    def tuple(*args)
      PyCall::Tuple[*args]
    end

    def type(pyobj)
      @type ||= PyCall.eval('type')
      @type.(pyobj)
    end

    def format_traceback(pyobj)
      @format_tb ||= import_module('traceback').format_tb
      @format_tb.(pyobj)
    end
  end

  extend Utils
end
