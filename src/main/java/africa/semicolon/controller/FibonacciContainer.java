package africa.semicolon.controller;

import africa.semicolon.services.FibonacciSequence;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FibonacciContainer {
    private final FibonacciSequence fibonacciSequence;

    public FibonacciContainer(FibonacciSequence fibonacciSequence) {
        this.fibonacciSequence = fibonacciSequence;
    }

    @GetMapping("/fibonacci/{n}")
    public String getFibonacci(@PathVariable int n) {
        long result = fibonacciSequence.calculateFibonacci(n);
        return "Fibonacci of " + n + " is: " + result;
    }
}



