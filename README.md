# FPGA Based UART AI Anomaly Detector 🚀

Bu proje, Verilog HDL kullanılarak tasarlanmış, UART üzerinden gelen verileri analiz eden ve basit bir yapay zeka (Tiny AI) mantığıyla anomali tespiti yapan bir donanım tasarımıdır.


## Proje Özellikleri
- **Dil:** Verilog HDL
- **Haberleşme:** UART (9600 Baud, 8N1)
- **Veri Güvenliği:** FIFO (First-In-First-Out) Buffer yapısı ile veri kaybı önleme.
- **AI Mantığı:** Gelen sensör verisi eşik değerini (Threshold > 100) aştığında otomatik "Anomali" tespiti.
- **Doğrulama:** Self-Checking Testbench ile %100 kod kapsamı.

## 📂 Dosya Yapısı
- `rtl/`: Sentezlenebilir donanım kodları (Baud Gen, UART RX/TX, FIFO, AI Controller).
- `tb/`: Simülasyon ve doğrulama kodları (Testbench).

##  Nasıl Çalıştırılır?
Proje **Icarus Verilog** kullanılarak test edilmiştir. Aşağıdaki komutlarla simülasyonu başlatabilirsiniz:

```bash
# Kodları derle
iverilog -o sim.out rtl/*.v tb/tb_uart_ai.v

# Simülasyonu çalıştır
vvp sim.out
