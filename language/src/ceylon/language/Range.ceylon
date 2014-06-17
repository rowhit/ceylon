
"A range of totally ordered, ordinal values generated by two 
 endpoints which are both [[Ordinal]] and [[Comparable]]: 
 [[first]] and [[last]].
 
 - If `first<last` the range is increasing,
 - if `first>last`, the range is decreasing, or
 - otherwise, if `first==last`, the range contains exactly
   one value.
 
 A range is always nonempty, containing at least one value.
 
 A range is a [[Sequence]].
 
 The _span_ operator `..` is an abbreviation for `Range`
 instantiation.
 
     for (i in min..max) { ... }
     if (char in 'A'..'Z') { ... }
 
 See the documentation for [[Ordinal]] for more
 information about the span and segment operators."
by ("Gavin")
see (`interface Ordinal`)
shared final class Range<Element>(first, last) 
        extends Object() 
        satisfies [Element+]
        given Element satisfies Ordinal<Element> & 
                                Comparable<Element> { 
    
    "The start of the range."
    shared actual Element first;
    
    "The end of the range."
    shared actual Element last;
    
    shared actual String string 
            => first.string + ".." + last.string;
    
    "Determines if the range is decreasing."
    shared Boolean decreasing => last<first; 
    
    Element next(Element x) 
            => decreasing then x.predecessor 
                          else x.successor;

    "The nonzero number of elements in the range."
    shared actual Integer size {
    	if (is Enumerable<Anything> last, 
    	    is Enumerable<Anything> first) {
    		return (last.integerValue - first.integerValue)
    		            .magnitude+1;
    	}
    	else {
    		variable Integer size = 1;
    		variable Element current=first;
    		while (current!=last) {
    			size++;
    			current = next(current);
    		}
            return size;
    	}
    }
    
    shared actual Boolean longerThan(Integer length) {
        if (length<1) {
            return true;
        }
        else if (is Enumerable<Anything> last, 
            is Enumerable<Anything> first) {
            return size>length;
        }
        else {
            variable Integer size = 1;
            variable Element current=first;
            while (current!=last) {
                if (size++>length) {
                    return true;
                }
                current = next(current);
            }
            return false;
        }
    }
    
    shared actual Boolean shorterThan(Integer length) {
        if (length<=1) {
            return false;
        }
        else if (is Enumerable<Anything> last, 
            is Enumerable<Anything> first) {
            return size<length;
        }
        else {
            variable Integer size = 1;
            variable Element current=first;
            while (current!=last) {
                if (size++==length) {
                    return false;
                }
                current = next(current);
            }
            return true;
        }
    }
    
    "The index of the end of the range."
    shared actual Integer lastIndex => size-1; 
    
    "The rest of the range, without the start of the range."
    shared actual Element[] rest {
        if (first==last) {
            return [];
        }
        else {
            return next(first)..last;
        }
    }
    
    "This range in reverse, with [[first]] and [[last]]
     interchanged.
     
     For any two range endpoints, `x` and `y`: 
     
         `(x..y).reversed == y..x`."
    shared actual Range<Element> reversed => last..first;
    
    "The element of the range that occurs [[index]] values 
     after the start of the range. Note that this operation 
     may be inefficient for large ranges."
    shared actual Element? getFromFirst(Integer index) {
        if (index<0) {
            return null;
        }
        else if (is Enumerable<Element> first) {
            value result = first.neighbour(decreasing then -index else index);
            return decreasing && result>=last || 
                  !decreasing && result<=last 
                          then result;
        }
        else {
            variable Integer current=0;
            variable Element x=first;
            while (current<index) {
                if (x==last) {
                    return null;
                }
                else {
                    ++current;
                    x=next(x);
                }
            }
            return x;
        }
    }
    
    "An iterator for the elements of the range."
    shared actual Iterator<Element> iterator() {
        if (is Enumerable<Element> first,
            is Enumerable<Element> last) {
            return EnumerableRangeBy(first, last, 1).iterator();
        } 
        object iterator
                satisfies Iterator<Element> {
            variable Element|Finished current = first;
            shared actual Element|Finished next() {
                Element|Finished result = current;
                if (!is Finished curr = current) {
                    if (decreasing 
                            then curr<=last 
                            else curr>=last) {
                        current = finished;
                    } 
                    else {
                        current = outer.next(curr);
                    }
                }
                return result;
            }
            string => "RangeIterator";
        }
        return iterator;
    }
    
    shared actual {Element+} by(Integer step) {
        "step size must be greater than zero"
        assert (step > 0);
        if (step == 1) {
            return this;
        }
        else if (is Enumerable<Element> first, 
                is Enumerable<Element> last) {
            return EnumerableRangeBy(first, last, step);
        }
        else {
            return super.by(step);
        }
    }
    
    "Returns a range of the same length and type as this
     range, with its endpoints shifted by the given number 
     of elements, where:
     
     - a negative [[shift]] measures 
       [[decrements|Ordinal.predecessor]], and 
     - a positive `shift` measures 
       [[increments|Ordinal.successor]]."
    shared Range<Element> shifted(Integer shift) {
        if (shift==0) {
            return this;
        }
        else if (is Enumerable<Element> first, 
                is Enumerable<Element> last) {
            return first.neighbour(shift)..last.neighbour(shift);
        }
        else {
            variable value shiftedFirst = first;
            variable value shiftedLast = last;
            value max = shift.magnitude;
            value increasing = shift.positive;
            variable value count = 0;
            while (count++<max) {
                if (increasing) {
                    shiftedFirst++;
                    shiftedLast++;
                }
                else {
                    shiftedFirst--;
                    shiftedLast--;
                }
            }
            return shiftedFirst..shiftedLast;
        }
    }
    
    shared actual Integer count(Boolean selecting(Element element)) {
        variable value e = first;
        variable value c = 0;
        while (containsElement(e)) {
            if (selecting(e)) {
                c++;
            }
            e = next(e);
        }
        return c;
    }
    
    "Determines if this range includes the given object."
    shared actual Boolean contains(Object element) {
        if (is Element element) {
            return containsElement(element);
        }
        else {
            return false;
        }
    }
    
    "Determines if this range includes the given value."
    shared actual Boolean occurs(Anything element) {
        if (is Element element) {
            return containsElement(element);
        }
        else {
            return false;
        }
    }
    
    "Determines if the range includes the given value."
    shared Boolean containsElement(Element x) 
            => decreasing then x<=first && x>=last
                          else x>=first && x<=last;
    
    shared actual Boolean includes(List<Anything> sublist) {
        if (sublist.empty) {
            return true;
        }
        if (is Range<Element> sublist) {
            return includesRange(sublist);
        }
        else {
            if (is Element start = sublist.first) {
                if (decreasing
                        then start>first || start<last
                        else start<first || start>last) {
                    return false;
                }
                variable value current=start;
                for (element in sublist) {
                    if (exists element) {
                        if (element!=current ||
                            decreasing
                                then current<last
                                else current>last) {
                            return false;
                        }
                        current = next(current);
                    }
                    else {
                        return false;
                    }
                }
                else {
                    return true;
                }
            }
            else {
                return false;
            }
        }
    }
    
    "Determines if this range includes the given range."
    shared Boolean includesRange(Range<Element> sublist) {
        return decreasing == sublist.decreasing &&
                first<=sublist.first<=last &&
                first<=sublist.last<=last;
    }
    
    "Determines if two ranges are the same by comparing
     their endpoints."
    shared actual Boolean equals(Object that) {
        if (is Range<Object> that) {
            //optimize for another Range
            return that.first==first && that.last==last;
        }
        else {
            //it might be another sort of List
            return super.equals(that);
        }
    }
    
    "Returns the range itself, since ranges are 
     immutable."
    shared actual Range<Element> clone() => this;
    
    shared actual Range<Element>|[] segment(Integer from, 
            Integer length) {
        if (length<=0 || from+length<0) {
            return [];
        }
        if (is Enumerable<Element> first) {
            Element xx; Element yy;
            if (decreasing) {
                value x = first.neighbour(-from);
                if (x<last) {
                    return [];
                }
                value y = first.neighbour(-from-length);
                yy = y<last then last else y;
                xx = x>first then first else x;
            }
            else {
                value x = first.neighbour(from);
                if (x>last) {
                    return [];
                }
                value y = first.neighbour(from+length-1);
                yy = y>last then last else y;
                xx = x<first then first else x;
            }
            return xx..yy;
        }
        else {
            variable value x=first;
            variable value i=0;
            while (i++<from) {
                x=next(x);
            }
            if (decreasing && x<last || 
                !decreasing && x>last) {
                return [];
            }
            variable value y=first;
            variable value j=0;
            while (j++<from+length-1 && 
                (decreasing && y>last || 
                !decreasing && y<last)) {
                y=next(y); 
            }
            return x..y;
        }
    }
    
    shared actual Range<Element>|[] span(Integer from, 
            Integer to) {
        if (from<0 && to<0) {
            return [];
        }
        if (is Enumerable<Element> first) {
            Element x; Element y;
            if (decreasing) {
                x = first.neighbour(-from);
                y = first.neighbour(-to);
            }
            else {
                x = first.neighbour(from);
                y = first.neighbour(to);
            }
            if (x<first && y<first ||
                x>last && y>last) {
                return [];
            }
            Element xx; Element yy;
            if (decreasing) {
                yy = (y<last then last) 
                else (y>first then first) 
                else y;
                xx = (x<last then last) 
                else (x>first then first) 
                else x;
            }
            else {
                yy = (y>last then last) 
                else (y<first then first) 
                else y;
                xx = (x>last then last) 
                else (x<first then first) 
                else x;
            }
            return xx..yy;
        }
        else {
            variable value x=first;
            variable value i=0;
            while (i++<from) {
                x=next(x);
            }
            variable value y=first;
            variable value j=0;
            while (j++<to) {
                y=next(y);
            }
            if (x>last && y>last) {
                return [];
            }
            Element xx; Element yy;
            if (decreasing) {
                yy = y<last then last else y;
                xx = x<last then last else x;
            }
            else {
                yy = y>last then last else y;
                xx = x>last then last else x;
            }
            return xx..yy;
        }
    }
    
    shared actual Range<Element>|[] spanTo(Integer to) {
        return to < 0 then [] else span(0, to);
    }
    
    shared actual Range<Element>|[] spanFrom(Integer from) {
        return span(from, size);
    }
    
    shared actual Range<Element>|[] skip(Integer skipping) {
        if (skipping <= 0) {
            return this;
        }
        Element elem;
        if (is Enumerable<Element> first) {
            elem = first.neighbour(decreasing then -skipping else skipping);
        }
        else {
            variable value x=0;
            variable value e = first;
            while (x++<skipping) {
                e = next(e);
            }
            elem = e;
        }
        return containsElement(elem) 
                then elem..last 
                else [];
    }
    
    shared actual Range<Element>|[] take(Integer taking) {
        if (taking <= 0) {
            return [];
        }
        Element elem;
        if (is Enumerable<Element> first) {
            elem = first.neighbour(decreasing then -taking+1 else taking-1);
        }
        else {
            variable value x=0;
            variable value e=first;
            while (++x<taking) {
                e = next(e);
            }
            elem = e;
        }
        return containsElement(elem) 
                then first..elem 
                else this;
    }

    "Returns the range itself, since a Range cannot
     contain nulls."
    shared actual Range<Element> coalesced => this;
    
    "Returns this range."
    shared actual Range<Element> sequence() => this;
    
}

class EnumerableRangeBy<Element>(Element first, Element last, 
    Integer step) 
        satisfies {Element+}
        given Element satisfies Comparable<Element> {
    shared actual Iterator<Element> iterator() {
        assert (is Enumerable<Element> first, 
                is Enumerable<Element> last);
        object iterator 
                satisfies Iterator<Element> {
            variable value current = first; 
            shared actual Element|Finished next() {
                value result = current;
                Element next;
                if (last<first) {
                    if (current < last) {
                        //TODO: handle overflow
                        return finished;
                    }
                    next = current.neighbour(-step);
                }
                else {
                    if (current > last) {
                        //TODO: handle overflow
                        return finished;
                    }
                    next = current.neighbour(step);
                }
                assert (is Enumerable<Element> next);
                current = next;
                return result;
            }
            string => "EnumerableRangeByIterator";
        }
        return iterator;
    }
}
