/*

Monte Carlo Hackathon created by Hafsa Demnati and Patrick Demichel @ Viridien 2024

The code compute a Call Option with a Monte Carlo method and compare the result with the analytical equation of Black-Scholes Merton : more details in the documentation
	
	
	
	Compilation : g++ -O BSM.cxx -o BSM



Exemple of run: ./BSM #simulations #runs



./BSM 100 1000000

Global initial seed: 21852687      argv[1]= 100     argv[2]= 1000000

value= 5.136359 in 10.191287 seconds



./BSM 100 1000000

Global initial seed: 4208275479      argv[1]= 100     argv[2]= 1000000

value= 5.138515 in 10.223189 seconds
	
	
	
	We want the performance and value for largest # of simulations as it will define a more precise pricing

If you run multiple runs you will see that the value fluctuate as expected

The large number of runs will generate a more precise value then you will converge but it require a large computation
	
	
	
	give values for ./BSM 100000 1000000

for ./BSM 1000000 1000000

for ./BSM 10000000 1000000

for ./BSM 100000000 1000000



We give points for best performance for each group of runs



You need to tune and parallelize the code to run for large # of simulations


*/

#include <iostream>
#include <cmath>
#include <random>
#include <vector>
#include <limits>
#include <algorithm>
#include <iomanip>   // For setting precision
#include "XoshiroCpp.hpp"
#include <omp.h>
#include <boost/random.hpp>
#include <boost/nondet_random.hpp>
#include <experimental/simd>

#define ui64 u_int64_t

#ifndef REAL
#define REAL double
#endif

#ifndef INSTRUCTION
#define INSTRUCTION ARM
#endif

using real = REAL;

inline real real_sqrt(real x) {
	if constexpr(std::is_same_v<real, double>) {
		return sqrt(x);
	} else if constexpr(std::is_same_v<real, float>) {
		return sqrtf(x);
	}
}

inline real real_exp(real x) {
	if constexpr(std::is_same_v<real, double>) {
		return exp(x);
	} else if constexpr(std::is_same_v<real, float>) {
		return expf(x);
	}
}



#include <sys/time.h>
double
dml_micros()
{
        static struct timezone tz;
        static struct timeval  tv;
        gettimeofday(&tv,&tz);
        return((tv.tv_sec*1000000.0)+tv.tv_usec);
}

// Function to generate Gaussian noise using Box-Muller transform
real gaussian_box_muller() {
	//This function is no longer used and has been moved to the main function so it could be parallelized
    static XoshiroCpp::Xoshiro256PlusPlus generator(std::random_device{}());
    static boost::normal_distribution<real> distribution(0.0, 1.0);
    return distribution(generator);
}


// Function to calculate the Black-Scholes call option price using Monte Carlo method
real black_scholes_monte_carlo(real S0, real K, real T, real r, real sigma, real q, ui64 num_simulations) {
    real sum_payoffs = 0.0;

#pragma omp parallel
	{
//I want to initialize the generator only once in each thread as a private variable, then parallelize the for loop
//with the generator private to each threadi
	XoshiroCpp::Xoshiro256PlusPlus generator(std::random_device{}());
	boost::normal_distribution<real> distribution(0.0, 1.0);
//On calcule les parties qui changent pas une seule fois
	//Gain de performance : 0 car le compilateur avait sans doute déjà fait l'optimisation rip
	real p1 =	(r - q - real(0.5f) * sigma * sigma) * T;
	real p2 = sigma * real_sqrt(T);
	
	std::experimental::native_simd<real> p1_vec = p1;
	std::experimental::native_simd<real> p2_vec = p2;
	
	std::experimental::native_simd<real> S0_vec = S0;
	std::experimental::native_simd<real> K_vec = K;
	std::experimental::native_simd<real> O_vec = 0.0f;



#pragma omp for reduction(+:sum_payoffs)
		for (ui64 i = 0; i < num_simulations; i += 4) {
			std::experimental::native_simd<real> Z;
			for (int j = 0; j < 4; ++j) {
				Z[j] = distribution(generator);
			}
//			real Z = distribution(generator);
			std::experimental::native_simd<real> ST = S0_vec * std::experimental::exp(p1_vec + (p2_vec * Z));
			std::experimental::native_simd<real> payoff = std::experimental::max(ST - K_vec, O_vec);
			sum_payoffs += std::experimental::reduce(payoff);
		}
};
    return real_exp(-r * T) * (sum_payoffs / num_simulations);

}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <num_simulations> <num_runs>" << std::endl;
        return 1;
    }

    ui64 num_simulations = std::stoull(argv[1]);
    ui64 num_runs        = std::stoull(argv[2]);

    // Input parameters
    real S0      = 100;                   // Initial stock price
    real K       = 110;                   // Strike price
    real T     = 1.0;                   // Time to maturity (1 year)
    real r     = 0.06;                  // Risk-free interest rate
    real sigma = 0.2;                   // Volatility
    real q     = 0.03;                  // Dividend yield

    // Generate a random seed at the start of the program using random_device
    boost::random_device rd;
    unsigned long long global_seed = rd();  // This will be the global seed

    std::cout << "Global initial seed: " << global_seed << "      argv[1]= " << argv[1] << "     argv[2]= " << argv[2] <<  std::endl;
    real sum = 0.0f;
    double t1=dml_micros();
    #pragma omp parallel for reduction(+:sum)
    for (ui64 run = 0; run < num_runs; ++run) {
	// std::vector<real> random_numbers(num_simulations);
	// #pragma omp parallel
	// {
    	//     XoshiroCpp::Xoshiro256PlusPlus generator(std::random_device{}());
	//     std::normal_distribution<real> distribution(0.0, 1.0);
    	//     #pragma omp for
    	//     for (ui64 i = 0; i < num_simulations; ++i) {
        // 	random_numbers[i] = distribution(generator);
    	//     }
	// }
	sum += black_scholes_monte_carlo(S0, K, T, r, sigma, q, num_simulations);
    }
	
    double t2=dml_micros();
		
    std::cout << std::fixed << std::setprecision(6) << " value= " << sum/num_runs << " in " << (t2-t1)/1000000.0 << " seconds" << std::endl;

    std::cout << "Performance in seconds : " << std::setprecision(3) << (t2-t1)/1000000.0   << std::endl;

    return 0;
}
