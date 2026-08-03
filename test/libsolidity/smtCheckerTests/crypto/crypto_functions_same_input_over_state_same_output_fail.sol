contract C {
	bytes data;
	bytes32 h;
	uint8 v;
	bytes32 r;
	bytes32 s;

	bytes32 kec;
	bytes32 sha;
	bytes32 rip;
	address erc;

	constructor(bytes memory _data, bytes32 _h, uint8 _v, bytes32 _r, bytes32 _s) {
		data = _data;
		h = _h;
		v = _v;
		r = _r;
		s = _s;

		kec = keccak256(data);
		sha = sha256(data);
		rip = ripemd160(data);
		erc = ecrecover(h, v, r, s);
	}

	function set(bytes memory _data, bytes32 _h, uint8 _v, bytes32 _r, bytes32 _s) public {
		data = _data;
		h = _h;
		v = _v;
		r = _r;
		s = _s;
	}

	function f() public view {
		bytes32 _kec = keccak256(data);
		bytes32 _sha = sha256(data);
		bytes32 _rip = ripemd160(data);
		address _erc = ecrecover(h, v, r, s);
		assert(_kec == kec);
		assert(_sha == sha);
		assert(_rip == rip);
		assert(_erc == erc);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Warning 6328: (693-712): CHC: Assertion violation happens here.\nCounterexample:\nh = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x0, sha = 0x0, rip = 0x0, erc = 0x0\n_kec = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd68\n_sha = 0x7e1d\n_rip = 0x20ad\n_erc = 0x2e15\n\nTransaction trace:\nC.constructor(_data, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe90a, 255, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc37, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdedd) -- counterexample incomplete; parameter name used instead of value\nState: h = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe90a, v = 255, r = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc37, s = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdedd, kec = 0x0, sha = 0x0, rip = 0x0, erc = 0x0\nC.set(_data, 0x0, 0, 0x0, 0x0) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x0, sha = 0x0, rip = 0x0, erc = 0x0\nC.f()
// Warning 6328: (716-735): CHC: Assertion violation happens here.\nCounterexample:\nh = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x2298, sha = 0x2e16, rip = 0x0, erc = 0x0\n_kec = 0x2297\n_sha = 0x2e15\n_rip = 0x7e1d\n_erc = 0x20ad\n\nTransaction trace:\nC.constructor(_data, 0x1d93, 27, 0x02ed, 0x0774) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x1d93, v = 27, r = 0x02ed, s = 0x0774, kec = 0x2298, sha = 0x2e16, rip = 0x0, erc = 0x0\nC.set(_data, 0x0, 0, 0x0, 0x0) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x2298, sha = 0x2e16, rip = 0x0, erc = 0x0\nC.f()
// Warning 6328: (739-758): CHC: Assertion violation happens here.\nCounterexample:\nh = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x0, sha = 0x2e16, rip = 0x20ae, erc = 0x0\n_kec = 0x0\n_sha = 0x2e15\n_rip = 0x20ad\n_erc = 0x7e1d\n\nTransaction trace:\nC.constructor(_data, 0x2296, 163, 0x2287, 0x04e5) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x2296, v = 163, r = 0x2287, s = 0x04e5, kec = 0x0, sha = 0x2e16, rip = 0x20ae, erc = 0x0\nC.set(_data, 0x0, 0, 0x0, 0x0) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x0, sha = 0x2e16, rip = 0x20ae, erc = 0x0\nC.f()
// Warning 6328: (762-781): CHC: Assertion violation happens here.\nCounterexample:\nh = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x2298, sha = 0x0, rip = 0x0, erc = 0x7e1e\n_kec = 0x2297\n_sha = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd1ea\n_rip = 0xffffffffffffffffffffffffffffffffffffdf52\n_erc = 0x7e1d\n\nTransaction trace:\nC.constructor(_data, 0x1445, 163, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0a, 0x222a) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x1445, v = 163, r = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0a, s = 0x222a, kec = 0x2298, sha = 0x0, rip = 0x0, erc = 0x7e1e\nC.set(_data, 0x0, 0, 0x0, 0x0) -- counterexample incomplete; parameter name used instead of value\nState: h = 0x0, v = 0, r = 0x0, s = 0x0, kec = 0x2298, sha = 0x0, rip = 0x0, erc = 0x7e1e\nC.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
