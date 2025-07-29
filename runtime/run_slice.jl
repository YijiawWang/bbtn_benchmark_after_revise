using OMEinsum
using OMEinsum: SlicedEinsum, SliceIterator, drop_slicedim, take_slice, view_slice, get_output_array, fill_slice!

function OMEinsum.einsum!(se::SlicedEinsum, @nospecialize(xs::NTuple{N,AbstractArray} where N), y, sx, sy, size_dict::Dict)
    length(se.slicing) == 0 && return einsum!(se.eins, xs, y, sx, sy, size_dict)
    iszero(sy) ? fill!(y, zero(eltype(y))) : rmul!(y, sy)
    it = SliceIterator(se, size_dict)
    eins_sliced = drop_slicedim(se.eins, se.slicing)
    # for slicemap in it

    @warn "using hacked sliced einsum, only run on one slice"
    slicemap = it[1]
    xsi = ntuple(i->take_slice(xs[i], it.ixsv[i], slicemap), length(xs))
    einsum!(eins_sliced, xsi, view_slice(y, it.iyv, slicemap), sx, true, it.size_dict_sliced)

    # end
    return y
end
function OMEinsum.einsum(se::SlicedEinsum, @nospecialize(xs::NTuple{N,AbstractArray} where N), size_dict::Dict)
    length(se.slicing) == 0 && return einsum(se.eins, xs, size_dict)
    it = SliceIterator(se, size_dict)
    # Note: the output array must be initialized to 0!
    res = get_output_array(xs, getindex.(Ref(size_dict), it.iyv), true)
    eins_sliced = drop_slicedim(se.eins, se.slicing)

    @warn "using hacked sliced einsum, only run on one slice"
    slicemap = it[1]
    xsi = ntuple(i->take_slice(xs[i], it.ixsv[i], slicemap), length(xs))
    resi = einsum(eins_sliced, xsi, it.size_dict_sliced)
    res = fill_slice!(res, it.iyv, resi, slicemap)

    return res
end