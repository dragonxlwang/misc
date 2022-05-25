#include <poll.h>
#include <stdlib.h>
#include <unistd.h>

#include "common/init/Init.h"
#include "common/logging/logging.h"

int main(int argc, char* argv[]) {
  facebook::initFacebook(&argc, &argv);

  int ids[2];

  auto rtv = pipe(ids);

  std::vector<pollfd> fds;

  fds.push_back({.fd = ids[0], .events = -1});
  fds.push_back({.fd = ids[1], .events = -1});

  ::poll(fds.data(), 2, -1);
  LOG(INFO) << fds[0].revents;
  LOG(INFO) << fds[1].revents;

  return 0;
}
