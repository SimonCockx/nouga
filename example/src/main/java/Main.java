import com.google.inject.*;
import com.google.inject.Module;
import primes.functions.IsPrime;
import primes.functions.Range;
import syntax.functions.RunExample;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        Injector injector = Guice.createInjector(new Module() {
            @Override
            public void configure(Binder binder) { }
        });
        Main main = new Main();
        injector.injectMembers(main);
        main.run();
    }

    @Inject
    private Range range;
    @Inject
    private IsPrime isPrime;
    public void run() {
        List<? extends Integer> r = range.evaluate(1, 100);
        System.out.println();
        for (int i = 0; i < 100; i ++) {
            if (isPrime.evaluate(i)) {
                System.out.println(i + " is a prime.");
            } else {
                System.out.println(i + " is not a prime.");
            }
        }
    }
}
