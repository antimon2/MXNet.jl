module Module
import ....MXNet: mx
import ..mx: DataBatch, AbstractDataProvider, AbstractDataBatch, DataBatchProvider
import ..mx: SymbolicNode, NDArray, Context, Executor, list_arguments, infer_shape, GRAD_NOP, AbstractExecutorGroup, list_outputs, DataParallelExecutorGroup, KVStore, OptimizationState, ADAM, UniformInitializer, set_params!, AbstractOptimizer, get_updater, update_params, provide_data, provide_label, AbstractEvalMetric, StubProvider, init, copy!

"""
    AbstractModule

A module represnets a computation component. The design purpose of a module is
that abstracts a computation unit, that one can run forward, backward, update parameters, etc.
We aim to make the APIs easy to use, especially in the case when we need to use
an imperative API to work with multiple modules (e.g. stochastic depth networks).

A module has several states:

* Initial state. Memory is not allocated yet, not ready for computation.
* Binded. Shapes for inputs, outputs, and parameters are all known, memory allocated.
* Parameter initialized. For modules with parameters, doing computation before intitializing
  the parameters might result in undefined outputs.
* Optimizer installed. An optimizer can be installed to a module. After this, the parameters.
  of the module can be updated according to the optimizers after gradients are computed
  (forward-backward).

In order for a module to interact with others, a module should be able to report the following
information in its raw stage (before binded):

* [`data_names`](@ref): Names of required data.
* [`output_names`](@ref): Names of the defined outputs.

And also the following richer information after being binded:

* State information:
  * [`isbinded`](@ref): indicating whether the memory buffers needed for computation
    have been allocated.
  * [`allows_training`](@ref): whether the module is binded for training (if binded).
  * [`isinitialized`](@ref): indicating whether the parameters of this module have
    been initialized.
  * [`hasoptimizer`](@ref): indicating wherger an optimizers is defined and intialized.
* Input/Output information:
  * [`data_shapes`](@ref):
  * [`label_shapes`](@ref):
  * [`output_shapes`](@ref):
* Parameters (for modules with parameters)
  * [`get_params`](@ref):
  * [`set_params`](@ref):
  * [`init_params`](@ref):
* Setup:
  * [`bind`](@ref):
  * [`init_optimizer`](@ref):
* Computation:
  * [`forward`](@ref):
  * [`backward`](@ref):
  * [`update!`](@ref):
  * [`get_outputs`](@ref):
  * [`get_input_grads`](@ref):
  * [`update_metric`](@ref):
* Optional:
  * [`get_symbol`](@ref): Access the associated `SymbolicNode` if the module has one.
    The returned value needs not to be constant (or defined)

Based on the underlying API a high-level API is implemented:
* [`fit`](@ref):
* [`predict`](@ref):
* [`score`](@ref):
* [`forward_backward`](@ref):
"""
abstract AbstractModule

##
# Names
##
"""
    data_names(self::AbstractModule) -> Vector{Symbol}
"""
function data_names(self::AbstractModule)
  throw(MethodError(data_names, (self,)))
end

"""
    output_names(self::AbstractModule) -> Vector{Symbol}
"""
function output_names(self::AbstractModule)
  throw(MethodError(output_names, (self,)))
end

##
# State information
##

"""
    isbinded(self::AbstractModule) -> Bool
"""
function isbinded(self::AbstractModule)
  throw(MethodError(isbinded, (self,)))
end

"""
    allows_training(self::AbstractModule) -> Bool
"""
function allows_training(self::AbstractModule)
  throw(MethodError(allows_training, (self,)))
end

"""
    isinitialized(self::AbstractModule) -> Bool
"""
function isinitialized(self::AbstractModule)
  throw(MethodError(isinitialized, (self,)))
end

"""
    hasoptimizer(self::AbstractModule) -> Bool
"""
function hasoptimizer(self::AbstractModule)
  throw(MethodError(hasoptimizer, (self,)))
end

##
#  Input/Output information
##

"""
"""
function data_shapes(self :: AbstractModule)
  throw(MethodError(data_shapes, (self,)))
end

"""
"""
function label_shapes(self :: AbstractModule)
  throw(MethodError(label_shapes, (self,)))
end

"""
"""
function output_shapes(self :: AbstractModule)
  throw(MethodError(output_shapes, (self,)))
end

##
# Parameters
##

"""
"""
function get_params(self :: AbstractModule)
  throw(MethodError(get_params, (self,)))
end

"""
"""
function set_params(self :: AbstractModule, arg_params, aux_params)
  throw(MethodError(set_params, (self, arg_params, aux_params)))
end

"""
"""
function init_params(self :: AbstractModule, args...)
  throw(MethodError(init_params, (self, args...)))
end

###
# Setup
###
"""
"""
function bind(self :: AbstractModule, )
end

"""
"""
function init_optimizer(self :: AbstractModule, )
end

###
# Computation
###
"""
"""
forward(self :: AbstractModule, data_batch :: DataBatch, is_train=nothing) = forward(self, StubProvider(), data_batch, is_train)
function forward(self :: AbstractModule, provider :: AbstractDataProvider, data_batch :: AbstractDataBatch, is_train=nothing)
  throw(MethodError(forward, (self, )))
end

"""
"""
function backward(self :: AbstractModule, )
end

"""
"""
function update(self :: AbstractModule, )
end

"""
"""
function get_outputs(self :: AbstractModule, )
end

"""
"""
function get_input_grads(self :: AbstractModule, )
end

"""
"""

update_metric(self :: AbstractModule, eval_metric::AbstractEvalMetric, batch::AbstractDataBatch) = update_metric(self, eval_metric, StubProvider(), batch)
function update_metric(self :: AbstractModule, eval_metric::AbstractEvalMetric, provider::AbstractDataProvider, batch::AbstractDataBatch)
  throw(MethodError(update_metric, (self, )))
end

###
# Optional
##
"""
    get_symbol(self::AbstractModule) -> Nullable{SymbolicNode}

Returns the associated [`SymbolicNode`](@ref) of the module. It might not be defined or change over time.
"""
function get_symbol(self::AbstractModule)
  return Nullable{SymbolicNode}()
end

###
# High-level
###

"""
"""
function fit(self::AbstractModule, train_data)

  error("Not yet implemented")
end

"""
    predict

Run prediction and collect the outputs.

# Arguments

* `eval_data` : `AbstractDataProvider`
* `num_batch` : Int
  Default is `None`, indicating running all the batches in the data iterator.
* `merge_batches` : `Bool`
  Default is `true`, see the doc for return values.
* `always_output_list` : `Bool`
  Default is `false`, see the doc for return values.

# Returns
When `merge_batches` is `true` (by default), the return value will be a vector
`[out1, out2, out3]`.  Where each element is concatenation of the outputs for
all the mini-batches. If further that `always_output_list` is `false` (by default),
then in the case of a single output, `out1` is returned instead of `[out1]`.
When `merge_batches` is `false`, the return value will be a nested list like
`[[out1_batch1, out2_batch1], [out1_batch2], ...]`. This mode is useful because
in some cases (e.g. bucketing), the module does not necessarily produce the same
number of outputs.
The objects in the results are `NDArray`s. If you need to work with julia array,
just call `Array{Float32}` on each of the `NDArray`.

# Examples
# TODO finish doc
An example of using predict for prediction::
    >>> #Predict on the first 10 batches of val_dataiter
    >>> mod.predict(eval_data=val_dataiter, num_batch=10)
"""
function predict(self::AbstractModule, eval_data;
                 num_batch=nothing, merge_batches=true, reset=true)
  @assert isbinded(self) && isinitialized(self)

  reset && reset!(eval_data)

  for (nbatch, eval_batch) in enumerate(eval_data)
    if num_batch !== nothing && nbatch == num_back
      break
    end
    forward(self, eval_batch, is_train=false)

    outputs = get_outputs(self)

    error("Not yet implemented")
  end
end

"""
    score(self::AbstractModule, eval_data, eval_metric; num_batch, batch_end_callback, reset=true, epoch=0)
"""
function score(self :: AbstractModule, eval_data, eval_metric; num_batch=nothing, batch_end_callback=nothing, reset=true, epoch=0)
  @assert isbinded(self) && isinitialized(self)

  reset && reset!(eval_data)
  reset!(eval_metric)

  for (nbatch, eval_batch) in enumerate(eval_data)
    if num_batch !== nothing && nbatch == num_back
      break
    end

    forward(self, eval_batch, is_train=false)
    update_metric(self, eval_metric, label(eval_batch))

    if batch_end_callback !== nothing
      error("Not implemented yet!")
    end
  end
  get(eval_metric)
end

"""
    forward_backward(self :: AbstractModule, data_batch)
"""
function forward_backward(self :: AbstractModule, data_batch)
  forward(self, data_batch, is_train=true)
  backward(self, data_batch)
end

# include implementations
include("symbol_module.jl")

end
