/**
 * @file hello-world.cpp
 * @brief A simple MPI program to verify the MPI cluster is working correctly.
 *
 * This program initializes the MPI environment, retrieves the rank of each
 * process along with the hostname of the machine, and prints this information
 * to the console.
 *
 * Compile with
 *   mpicxx -o hello-world.out hello-world.cpp
 *
 */

#include <mpi.h>
#include <unistd.h>

#include <iomanip>
#include <iostream>

using std::cout;
using std::endl;
using std::setw;

const int MAIN_NODE = 0;

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(&argc, &argv);

    int world_size = -1,  // Size of the communicator.
        world_rank = -1;  // Rank of the process.

    char hostname[256];

    // Get the number of processes.
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process.
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get hostname of the machine.
    gethostname(hostname, sizeof(hostname));

    // Print the hostname and rank of each node.
    cout << hostname << ": Rank: " << setw(3) << world_rank << endl;

    // Synchronize all processes here.
    MPI_Barrier(MPI_COMM_WORLD);

    // Only one node should output the total number of processors.
    if (MAIN_NODE == world_rank)
        cout << "\nTotal Processors: " << world_size << endl;

    // Finalize the MPI environment. Must be done to clean up and release
    // resources.
    MPI_Finalize();

    return 0;
}
