package africa.semicolon.services;

import org.springframework.stereotype.Service;

@Service
public class FibonacciSequence implements Fibonacci{

    @Override
    public int calculateFibonacci(int n) {
        if (n <= 1) return n;
        int a = 0, b = 1;
        for (int i = 2; i <= n; i++) {
            int next = a + b;
            a = b;
            b = next;
        }
        return b;
    }
}
