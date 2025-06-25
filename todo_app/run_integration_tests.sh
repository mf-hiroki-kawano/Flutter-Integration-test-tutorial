#!/bin/bash

# Integrationテストを実行するスクリプト

echo "Running integration tests..."

# デバイスが接続されているか確認
flutter devices

# Integrationテストを実行
flutter test integration_test/app_test.dart

echo "Integration tests completed!" 