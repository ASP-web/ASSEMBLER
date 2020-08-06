#include <iostream>
#include <chrono>

extern "C" {
	void _GOST_encr(uint8_t* byPKey, uint32_t& dwA1, uint32_t& dwA0);
	void _GOST_decr(uint8_t* byPKey, uint32_t& dwA1, uint32_t& dwA0);
}

using namespace	std;

int main(int argc, char** argv[]) {

	uint8_t key[32] = { 0xff, 0xfe, 0xfd, 0xfc, 0xfb, 0xfa, 0xf9, 0xf8, 0xf7, 0xf6, 0xf5, 0xf4, 0xf3, 0xf2, 0xf1, 0xf0, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff };
	uint32_t test_A1 = 0xfedcba98;
	uint32_t test_A0 = 0x76543210;

	uint32_t NumBlocks = 100000;

	chrono::time_point<chrono::high_resolution_clock> start, stop;

	start = chrono::high_resolution_clock::now();
	for (uint64_t i = 0; i < NumBlocks; i++) {
		_GOST_encr(key, test_A1, test_A0);
		cout << hex << test_A1 << endl << test_A0 << endl;
	}
	stop = std::chrono::high_resolution_clock::now();
	cout << dec << "ASSEMBLER ENCRYPTIOM TIME: " << chrono::duration_cast<chrono::microseconds>(stop - start).count() << endl;


	return 0;
}