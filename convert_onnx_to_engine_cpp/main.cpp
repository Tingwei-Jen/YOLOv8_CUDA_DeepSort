#include <iostream>
#include "engine.h"

int main(int argc, char* argv[])
{
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <onnx_path> <engine_path> <max_batch_size>" << std::endl;
        return 1;
    }

    // 取得 ONNX 模型和 Engine 路徑
    std::string onnxPath = argv[1];
    std::string enginePath = argv[2];
    int maxBatchSize = std::stoi(argv[3]);

    // engine options
    Options options;
    options.precision = Precision::FP32;
    options.optBatchSize = 1;
    options.maxBatchSize = maxBatchSize;

    // create engine
    Engine engine(options);

    // build engine
    bool succ = engine.buildEngineFromOnnx(onnxPath, enginePath);
    if (succ) {
        std::cout << "Successfully built engine from ONNX model." << std::endl;
    } else {
        std::cerr << "Failed to build engine from ONNX model." << std::endl;
    }

    // check engine
    std::cout << "Loading engine from disk..." << std::endl;
    succ = engine.loadEngineNetwork(enginePath);

    return 0;
}