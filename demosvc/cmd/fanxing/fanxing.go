package main

import (
	"fmt"
	"reflect"
	"sort"
)

//	func main() {
//		//var x int = 43
//		//var y string = "hello world"
//		//
//		//fmt.Println(reflect.TypeOf(x), reflect.TypeOf(y))
//		//fmt.Println(reflect.ValueOf(x), reflect.ValueOf(y))
//		//fmt.Println(reflect.ValueOf(x), reflect.ValueOf(y))
//
// }
func Add(a, b int) int {
	return a + b
}

type Persion struct {
	Name string
	Agen int
}

type RegistryFunc func() Persion

type SliceInt []int
type SliceString []string
type SliceInt32 []int32
type Slice[T ~int | ~string | ~int32 | ~float32] []T

type SliceI[T interface{}] []interface{}

func AddT[T ~int | ~string | ~int32 | ~float32](a, b T) T {
	return a + b
}

func Ptr[T ~int | ~string | ~int32 | ~float32](a T) *T {
	return &a
}

func PtrVal[T any](a *T) T {
	return *a
}

type SliceAny[T any] []T

//type any = interface{}

type Map[K comparable, V any] map[K]V

type SliceTest[T ~int] []T

type MyInt int

type MyInt2[T any] MyInt

type Int interface {
	~int | ~int8 | ~int16 | ~int32 | ~float32 | ~float64
}

type Ptr1[T int | string] *T

type Ptr2[T any] []T

type MYMap[K comparable, V any] map[K]V

type ChanelT[T any] chan T

type InterfaceT[T Int] interface {
	Value() T
	Type() reflect.Type
}

type Mystruct[T Int] struct {
	Data int
	Name string
}

func (my *Mystruct[T]) Value() T {
	return T(my.Data)
}

func (my *Mystruct[T]) Type() reflect.Type {
	return reflect.TypeOf(my.Data)
}

type InterfaceTImpl1 struct {
	a int
}

func (impl *InterfaceTImpl1) Value() int {
	return impl.a
}

func (impl *InterfaceTImpl1) Type() reflect.Type {
	return reflect.TypeOf(impl.a)
}

type InterfaceTImpl2 int32

func (impl InterfaceTImpl2) Value() int32 {
	return int32(32)
}

func (impl InterfaceTImpl2) Type() reflect.Type {
	return reflect.TypeOf(32)
}

type Test2[T *int,] int
type Test3[T *int32 | *float32,] []T

type Test4[T interface{ *int | *float32 }] []T

func GetType[T int | string](t T) T {
	v := reflect.ValueOf(&t)
	fmt.Println(v.Kind())
	fmt.Println("=====vType", v.Elem())
	vType := reflect.TypeOf(&t)
	fmt.Println("=====vType", vType.Elem())
	return t
}

func Testv1[T int | int32](a, b T) T {
	result := func(a, b T) T {
		return a + b
	}
	return result(a, b)
}

func Filter[T any](src []T, f func(T) bool) []T {
	result := []T{}
	for _, v := range src {
		if f(v) {
			result = append(result, v)
		}
	}
	return result
}
func Map1[D, S, T any](src []S, srcD []D, f func(S) T) []T {
	result := []T{}
	for _, v := range src {
		result = append(result, f(v))
	}
	return result
}

func Reduce[T any](src []T, f func(T, T) T) T {
	if len(src) == 1 {
		return src[0]
	}
	return f(src[0], Reduce(src[1:], f))
}

type DemoStruct[K comparable, V any] struct {
	Data map[K]V
}

func NewDemoStruct[K comparable, V any]() *DemoStruct[K, V] {
	return &DemoStruct[K, V]{
		Data: make(map[K]V),
	}
}

func (d *DemoStruct[K, V]) Set(k K, v V) {
	d.Data[k] = v
}

func (d *DemoStruct[K, V]) Get(k K) V {
	return d.Data[k]
}
func (d *DemoStruct[K, V]) Del(k K) {
	delete(d.Data, k)
}
func (d *DemoStruct[K, V]) Len() int {
	return len(d.Data)
}
func (d *DemoStruct[K, V]) Keys() []K {
	keys := []K{}
	for k := range d.Data {
		keys = append(keys, k)
	}
	return keys
}
func (d *DemoStruct[K, V]) Values() []V {
	values := []V{}
	for _, v := range d.Data {
		values = append(values, v)
	}
	return values
}
func (d *DemoStruct[K, V]) PrintAll() {
	for k, v := range d.Data {
		fmt.Println(k, v)
	}
}

func (d *DemoStruct[K, V]) Exists(k K) bool {
	_, ok := d.Data[k]
	if ok {
		return true
	}
	return false
}

func (d *DemoStruct[K, V]) Equal(a, b K) bool {

	return a == b
}

type Student struct {
	Num  int
	Name string
}

type BaseInterface interface {
	Name() string
	Age() int
}

type ATest[T BaseInterface] []T

func BasicIF[T BaseInterface](b T) {
	b.Age()
	b.Name()
}

func BasicIF2(b BaseInterface) {
	b.Age()
	b.Name()
}

type BaseInterface2[T int | int32 | string | float32] interface {
	Func1(in T) (out T)
	Func2() T
}

type BTest1[T BaseInterface2[int]] []T
type BTest2[T BaseInterface2[int32]] []T
type BTest3[T int] BaseInterface2[T]

func BTestFunc1[T BaseInterface2[int]](t T) {
	t.Func2()
}
func BTestFunc2(t BaseInterface2[int32]) {
	t.Func2()
}

type BasicInterface2Impl struct{}

func (b BasicInterface2Impl) Func1(in int) (out int) {
	panic("implement me")
}
func (b BasicInterface2Impl) Func2() int {
	panic("implement me")
}

// 举例2-不是BasicInterface2的实现
type BasicInterface2Impl2 struct{}

func (b BasicInterface2Impl2) Func1(in string) (out string) {
	panic("implement me")
}
func (b BasicInterface2Impl2) Func2() int {
	panic("implement me")
}

// 举例3-不是BasicInterface2的实现
type BasicInterface2Impl3 struct{}

func (b BasicInterface2Impl3) Func1(in float32) (out float32) {
	panic("implement me")
}
func (b BasicInterface2Impl3) Func2() float32 {
	panic("implement me")
}

type Comple interface {
	int | int32 | string
}

type IntI interface {
	int | int32 | int8 | int16 | int32 | int64
}

type FI interface {
	float32 | float64
}

type IntAndFloat interface {
	IntI | FI
}

type IntExcepInt8 interface {
	IntI
	int
}

type CommonInterface2 interface {
	int | int32 | struct {
		Data string
	}
	Func1() string
}

type CommonInterface2Impl struct{}

func (c *CommonInterface2Impl) Func1() string {
	return ""
}

type CommonInterface2Impl2 int

func (c *CommonInterface2Impl2) Func1() string {
	return ""
}

type CommonInterface2Impl3 float64

func (c *CommonInterface2Impl3) Func1() float64 {
	return 1.1
}

func DoCf[T CommonInterface2](t T) {
	t.Func1()
}

type Com3[T string | float32] interface {
	~int | ~int8 | ~struct {
		Data T
	}
	Func2() T
}

type Com3Impl int

func (c *Com3Impl) Func2() int {
	return 1
}

type Com3Impl1 int

func (c *Com3Impl1) Func2() float32 {
	return 1.1
}

type Com3Impl2[T int] struct {
	Data T
}

func (c *Com3Impl2[int]) Func2() string {
	return cast.ToString(c.Data)
}

func main() {
	var a1 BaseInterface
	//var a2 BaseInterface2[int]
	fmt.Println(reflect.TypeOf(a1))
	demoStruct := NewDemoStruct[int, string]()
	demoStruct.Set(1, "de1")
	demoStruct.Set(2, "de2")
	demoStruct.PrintAll()

	sMap := NewDemoStruct[int, Student]()
	sMap.Set(1, Student{
		Num:  1,
		Name: "stu1",
	})

	sMap.Set(2, Student{
		Num:  2,
		Name: "stu2",
	})
	sMap.PrintAll()

	result := Filter([]int{1, 2, 3, 4, 5, 67, 7}, func(i int) bool {
		if i > 3 {
			return true
		}
		return false
	})
	sort.Slice(result, func(i, j int) bool {
		return result[i] < result[j]
	})
	fmt.Println("result:", result)
	mapTest := Map1[int, int, int]([]int{1, 23, 4}, []int{}, func(i int) int {
		return i + 6
	})
	fmt.Println("mapTest:", mapTest)

	resultReduce := Reduce[int]([]int{1, 23, 4}, func(i int, v int) int {
		return i + 6
	})
	fmt.Println("resultReduce:", resultReduce)
	GetType(90)
	var interfaceT1 InterfaceT[int]
	interfaceT1 = &InterfaceTImpl1{a: 1}
	fmt.Println(interfaceT1.Value())
	fmt.Println(reflect.TypeOf(interfaceT1.Value()))
	interfaceT1 = &Mystruct[int]{Data: 2}
	fmt.Println(interfaceT1.Value())
	fmt.Println(reflect.TypeOf(interfaceT1.Value()))
	var interfaceT2 InterfaceT[int32] = InterfaceTImpl2(11)
	fmt.Println("interfaceT2:==", interfaceT2.Value())
	fmt.Println(reflect.TypeOf(interfaceT2.Value()))
	//var tst SliceTest[MyInt]

	//var s1 SliceI[string]
	//var i2 SliceI[int]
	//var i3 SliceI[interface{}]
	//sliceMake := make([]Slice[int], 0)
	intPtr1 := Ptr[int](2)
	fmt.Println(reflect.TypeOf(intPtr1))

	intPtr2 := Ptr(1)
	fmt.Println(reflect.TypeOf(intPtr2))

	strPtr1 := Ptr("str1")
	fmt.Println(reflect.TypeOf(strPtr1))

	strPtr2 := PtrVal(strPtr1)
	fmt.Println(reflect.TypeOf(strPtr2))
	fmt.Println("reflect.ValueOf(&strPtr2).Elem()", reflect.ValueOf(&strPtr2).Elem())

	var a Slice[int] = []int{1, 2, 3}
	var b Slice[float32] = []float32{1.1, 2.2, 3.3}
	fmt.Println(reflect.TypeOf(a), reflect.TypeOf(b))
	var d func()
	var f func()

	fmt.Println(reflect.ValueOf(&d).Pointer())
	fmt.Println(reflect.ValueOf(&f).Pointer())
	p := &Persion{Name: "steing", Agen: 1}
	p1 := Persion{Name: "steing", Agen: 1}

	vt := reflect.TypeOf(&p1).Elem()
	v := reflect.ValueOf(&p).Elem()
	key := reflect.TypeOf(p).PkgPath()
	fmt.Println("type elem", vt, "======,", key)
	fmt.Println("value elem", v.Type().Elem())
	fmt.Println(vt.Kind() == reflect.Ptr, vt.CanSeq2())
	fmt.Println(v.CanSet())

	var s RegistryFunc
	s = func() Persion {
		return Persion{}
	}

	sType := reflect.TypeOf(&s)
	fmt.Println("kind", sType.Kind())
	fmt.Println("name", sType.Name())
	fmt.Println("sType", sType)
	fmt.Println("sType", sType.Elem())

	//func (f *frameworkImpl) getExtensionPoints(plugins *config.Plugins) []extensionPoint {
	//	return []extensionPoint{
	//{&plugins.PreFilter, &f.preFilterPlugins},
	//{&plugins.Filter, &f.filterPlugins},
	//{&plugins.PostFilter, &f.postFilterPlugins},
	//{&plugins.Reserve, &f.reservePlugins},
	//{&plugins.PreScore, &f.preScorePlugins},
	//{&plugins.Score, &f.scorePlugins},
	//{&plugins.PreBind, &f.preBindPlugins},
	//{&plugins.Bind, &f.bindPlugins},
	//{&plugins.PostBind, &f.postBindPlugins},
	//{&plugins.Permit, &f.permitPlugins},
	//{&plugins.PreEnqueue, &f.preEnqueuePlugins},
	//{&plugins.QueueSort, &f.queueSortPlugins},
	//}
	//}

}
