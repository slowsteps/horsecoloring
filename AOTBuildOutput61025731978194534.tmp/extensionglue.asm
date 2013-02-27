	.syntax unified
	.section	__TEXT,__cstring,cstring_literals
	.globl	_productStoreExtInitializer_name
	.align	4
_productStoreExtInitializer_name:
	.asciz	 "productStoreExtInitializer"

	.globl	_productStoreExtFinalizer_name
	.align	4
_productStoreExtFinalizer_name:
	.asciz	 "productStoreExtFinalizer"

	.section	__DATA,__const
	.globl	_g_com_adobe_air_fre_fmap
	.align	4
_g_com_adobe_air_fre_fmap:
	.long	_productStoreExtInitializer_name
	.long	_productStoreExtInitializer
	.long	_productStoreExtFinalizer_name
	.long	_productStoreExtFinalizer
	.space	8



.subsections_via_symbols
